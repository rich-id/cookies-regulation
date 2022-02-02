import './../scss/cookies-regulation.scss';
import './cookies-regulation-services';
import { Elm } from './../elm/CookiesRegulation.elm';
import { v4 as uuidv4 } from 'uuid';

const DECISION_COOKIE_NAME = 'cookie_regulation_decision';

class CookiesRegulation {
    constructor() {
        this.configurationLoader = new ConfigurationLoader();
        this.decisionStorage = new DecisionStorage();
        this.cookieManager = new CookieManager();
    }

    init (config) {
        this.configurationLoader.loadConfiguration(config);

        const decision = this.decisionStorage.read();

        this.cookieManager.cleanCookies(decision.preferences);

        if (typeof decision.preferences !== 'undefined' && decision.preferences.length === 0) {
            for (var serviceId in config.services) {
                let serviceConfiguration = config.services[serviceId];

                if (typeof serviceConfiguration.enabledByDefault !== 'undefined' && serviceConfiguration.enabledByDefault === true) {
                    decision.preferences.push([serviceId, true]);
                }
            }
        }

        this.initElm(decision, config);
    }

    openModal () {
        window.cookiesRegulationBlock.ports.openModal.send(null);
    }

    initElm (decision, config) {
        let container = document.createElement('div');
        document.body.appendChild(container);

        window.cookiesRegulationBlock = Elm.CookiesRegulation.init({
            node: container,
            flags: {
                preferences: decision.preferences,
                decisionMetadata: decision.metadata,
                config: config
            },
        });

        window.cookiesRegulationBlock.ports.modalOpened.subscribe(
            function () {
                document.querySelector('body').classList.add('cookies-regulation-modal-open');
            }
        );

        window.cookiesRegulationBlock.ports.modalClosed.subscribe(
            function () {
                document.querySelector('body').classList.remove('cookies-regulation-modal-open');
            }
        );

        window.cookiesRegulationBlock.ports.initializeService.subscribe((serviceName) => this.initializeService(serviceName));
        window.cookiesRegulationBlock.ports.setPreferences.subscribe((data) => this.setPreferences(data));
    }

    initializeService (serviceName) {
        const service = window.cookiesRegulationConfig.services[serviceName];

        if (!service) {
            console.error('Failed to load the service "' + serviceName + '". Please check your configuration.');
            return;
        }

        if (typeof service.initializationCallback === 'undefined' || service.initializationCallback === null) {
            return;
        }

        service.initializationCallback();
    }

    setPreferences (data) {
        let preferences = data[0];
        let reloadPage = data[1];

        let metadata = { uuid: uuidv4(), date: new Date().toISOString() };
        let decision = { preferences: preferences, metadata: metadata };

        this.decisionStorage.write(decision);
        window.cookiesRegulationBlock.ports.receiveDecisionMetadata.send(metadata);

        window.cookiesRegulationConfig.decisionLogCallback(decision);

        if (reloadPage) {
            window.location.reload();
        }
    }
}

class ConfigurationLoader {
    // Create the configuration from the declared services
    loadConfiguration (config) {
        this.loadGeneralConfiguration(config);
        this.loadServicesConfiguration(config);
    }

    loadGeneralConfiguration (config) {
        if (typeof config.decisionLogCallback !== 'function') {
            console.log('No decision log callback, logging is a requirement with GDPR');

            config.decisionLogCallback = () => {
                console.log('No decision log callback, logging is a requirement with GDPR');
            };
        }
    }

    loadServicesConfiguration (config) {
        for (var serviceId in config.services) {
            let serviceConfiguration = config.services[serviceId];

            if (!this.isServiceAutoconfigured(serviceConfiguration)) {
                continue;
            }

            if (this.isAutoconfiguredServiceValid(serviceConfiguration)) {
                this.autoconfigureService(serviceConfiguration);
            } else {
                delete config.services[serviceId];
            }
        }

        window.cookiesRegulationConfig = config;
    }

    isServiceAutoconfigured (serviceConfiguration) {
        return typeof serviceConfiguration.service !== 'undefined';
    }

    isAutoconfiguredServiceValid(serviceConfiguration) {
        let service = serviceConfiguration.service;

        if (typeof window.cookiesRegulationServices[service] === 'undefined') {
            console.log('No auto-configured service exists with the ' + service + ' id');

            return false;
        }

        return this.isAutoconfiguredServiceOptionsValid(serviceConfiguration, service);
    }

    isAutoconfiguredServiceOptionsValid(serviceConfiguration, service) {
        let options = serviceConfiguration.options ? serviceConfiguration.options : {};
        let definedOptions = [];

        for (let option in options) {
            definedOptions.push(option);
        }

        let requiredOptions = window.cookiesRegulationServices[service].requiredOptions;
        let hasMissingOption = false;

        for (let i = 0; i < requiredOptions.length; i++) {
            let requiredOption = requiredOptions[i];

            if (!definedOptions.includes(requiredOption)) {
                hasMissingOption = true;

                console.log('Missing required option ' + requiredOption);
                return false;
            }
        }

        return true;
    }

    autoconfigureService (serviceConfiguration) {
        let service = serviceConfiguration.service;
        let options = serviceConfiguration.options;

        serviceConfiguration.mandatory = false;
        serviceConfiguration.initializationCallback = function () {
            window.cookiesRegulationServices[service].callback(options);
        };

        if (typeof serviceConfiguration.cookiesIdentifiers === 'undefined') {
            serviceConfiguration.cookiesIdentifiers = window.cookiesRegulationServices[service].cookiesIdentifiers;
        }

        delete serviceConfiguration.service;
        delete serviceConfiguration.options;
    }
}

class DecisionStorage {
    read () {
        return this.decodeDecisionCookie(this.readDecisionCookie());
    }

    readDecisionCookie () {
        let cookieArr = document.cookie.split(";");

        for(let cookieId in cookieArr) {
            let cookiePair = cookieArr[cookieId].split("=");

            if (cookiePair[0].trim() === DECISION_COOKIE_NAME) {
                return decodeURIComponent(cookiePair[1]);
            }
        }

        return null;
    }

    decodeDecisionCookie(encodedDecision) {
        if (encodedDecision === null || encodedDecision === '') {
            return this.emptyDecision();
        }

        return JSON.parse(encodedDecision);
    }

    emptyDecision () {
        return { preferences: [], metadata: null };
    }

    write (decision) {
        let encodedDecision = this.encodeDecisionCookie(decision);

        if (encodedDecision === null) {
            return;
        }

        this.writeDecisionCookie(encodedDecision);
    }

    encodeDecisionCookie(decision) {
        return JSON.stringify(decision);
    }

    writeDecisionCookie(encodedDecision) {
        const expirationDate = new Date();
        expirationDate.setMonth(expirationDate.getMonth() + 6);

        const expires = "expires=" + expirationDate.toUTCString();
        const secure = location.protocol === 'https:' ? '; Secure' : '';

        document.cookie = DECISION_COOKIE_NAME + '=' + encodedDecision + '; ' + expires + '; path=/;' + secure + '; samesite=lax';
    }
}

class CookieManager {
    cleanCookies (preferences) {
        let enabledServices = [];

        for (let preferenceId in preferences) {
            let preference = preferences[preferenceId];

            if (preference[1]) {
                enabledServices.push(preference[0])
            }
        }

        for (let serviceId in window.cookiesRegulationConfig.services) {
            let service = window.cookiesRegulationConfig.services[serviceId];

            let notMandatory = typeof service.mandatory === 'undefined' || !service.mandatory;
            let isEnabled = enabledServices.includes(serviceId)

            if (notMandatory && !isEnabled) {
                this.cleanServiceCookies(service);
            }
        }
    }

    // Delete cookies from a service
    cleanServiceCookies (service) {
        for (let identifierId in service.cookiesIdentifiers) {
            let identifier = service.cookiesIdentifiers[identifierId];
            let regex = new RegExp(identifier);

            let cookiesName = this.getAllCookiesName();

            for (let cookieId in cookiesName) {
                let cookieName = cookiesName[cookieId];

                if (regex.test(cookieName)) {
                    this.deleteCookie(cookieName);
                }
            }
        }
    }

    // Delete a cookie by name
    deleteCookie (cookieName) {
        document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/;';
        document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/; domain=.' + location.hostname + ';';
        document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/; domain=.' + location.hostname.split('.').slice(-2).join('.') + ';';
    }

    // Returns the name of all cookies
    getAllCookiesName () {
        return document.cookie.split(";")
            .map(test => test.split("=")[0].trim());
    }
}

var instance = new CookiesRegulation();

module.exports = {
    init: (config) => instance.init(config),
    openModal: () => instance.openModal(),
};
