import './../scss/cookies-regulation.scss';
import './cookies-regulation-services';
import { Elm } from './../elm/CookiesRegulation.elm';

module.exports = {
    init: function (config) {
        buildAndStoreConfiguration(config);

        let container = document.createElement('div');
        document.body.appendChild(container);

        const preferences = this.getPreferences();

        cleanCookies(preferences);

        window.cookiesRegulationBlock = Elm.CookiesRegulation.init({
            node: container,
            flags: {
                preferences: preferences,
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

        window.cookiesRegulationBlock.ports.initializeService.subscribe(this.initializeService);
        window.cookiesRegulationBlock.ports.setPreferences.subscribe(this.setPreferences);
    },

    initializeService: function (serviceName) {
        const service = window.cookiesRegulationConfig.services[serviceName];

        if (!service) {
            console.error('Failed to load the service "' + serviceName + '". Please check your configuration.');
            return;
        }

        if (typeof service.initializationCallback === 'undefined' || service.initializationCallback === null) {
            return;
        }

        service.initializationCallback();
    },

    openModal: function () {
        window.cookiesRegulationBlock.ports.openModal.send(null);
    },

    setPreferences: function(data) {
        let preferences = data[0];
        let reloadPage = data[1];

        let encodedPreferences = encodeCookiePreferencesData(preferences);

        if (encodedPreferences === null) {
            return;
        }

        const expirationDate = new Date();
        expirationDate.setMonth(expirationDate.getMonth() + 6);

        const expires = "expires=" + expirationDate.toUTCString();
        const secure = location.protocol === 'https:' ? '; Secure' : '';

        document.cookie = 'cookie_preferences=' + encodedPreferences + '; ' + expires + '; path=/;' + secure + '; samesite=lax';

        if (reloadPage) {
            window.location.reload();
        }
    },

    getPreferences: function() {
        let cookie = getReferencesCookie();

        if (cookie === null) {
            return [];
        }
        return decodeCookiePreferencesData(cookie);
    }
}

var getReferencesCookie = function () {
    let cookieArr = document.cookie.split(";");

    for(let cookieId in cookieArr) {
        let cookiePair = cookieArr[cookieId].split("=");

        if (cookiePair[0].trim() === 'cookie_preferences') {
            return decodeURIComponent(cookiePair[1]);
        }
    }

    return null;
};

var encodeCookiePreferencesData = function (preferences) {
    if (preferences.length === 0) {
        return null;
    }

    return JSON.stringify(preferences);
};

var decodeCookiePreferencesData = function (encodedPreferences) {
    if (encodedPreferences === null || encodedPreferences === '') {
        return [];
    }

    return JSON.parse(encodedPreferences);
};

var buildAndStoreConfiguration = function (config) {
    for (var serviceId in config.services) {
        let service = config.services[serviceId].service;
        let options = config.services[serviceId].options ? config.services[serviceId].options : {};

        if (typeof service === 'undefined') {
            continue;
        }

        if (typeof window.cookiesRegulationServices[service] === 'undefined') {
            console.log('No auto-configured service exists with the ' + service + ' id');

            delete config.services[serviceId];
            continue;
        }

        let definedOptions = [];

        for (let option in options) {
            definedOptions.push(option);
        }

        let requiredOptions = window.cookiesRegulationServices[service].requiredOptions;
        let hasMissingOption = false;

        for(let i = 0; i < requiredOptions.length; i++) {
            let requiredOption = requiredOptions[i];

            if (!definedOptions.includes(requiredOption)) {
                hasMissingOption = true;

                console.log('Missing required option ' + requiredOption);
                delete config.services[serviceId];
                break;
            }
        }

        if (!hasMissingOption) {
            let options = config.services[serviceId].options;

            config.services[serviceId].mandatory = true;
            config.services[serviceId].initializationCallback = function () {
                window.cookiesRegulationServices[service].callback(options);
            };

            if (typeof config.services[serviceId].cookiesIdentifiers === 'undefined') {
                config.services[serviceId].cookiesIdentifiers = window.cookiesRegulationServices[service].cookiesIdentifiers;
            }

            delete config.services[serviceId].service;
            delete config.services[serviceId].options;
        }
    }

    window.cookiesRegulationConfig = config;
};

var cleanCookies = function (preferences) {
    let enabledServices = [];

    for (let preferenceId in preferences) {
        let preference = preferences[preferenceId];

        if (preference[1]) {
            enabledServices.push(preference[0])
        }
    }

    for (let serviceId in window.cookiesRegulationConfig.services) {
        let service = window.cookiesRegulationConfig.services[serviceId];

        let mandatory = typeof service.mandatory !== 'undefined' && service.mandatory;
        let isEnabled = enabledServices.includes(serviceId)

        if (mandatory && !isEnabled) {
            cleanServiceCookies(serviceId, service);
        }
    }
};

var cleanServiceCookies = function (serviceId, service) {
    for (let identifierId in service.cookiesIdentifiers) {
        let identifier = service.cookiesIdentifiers[identifierId];
        let regex = new RegExp(identifier);

        let cookiesName = getAllCookiesName();

        for (let cookieId in cookiesName) {
            let cookieName = cookiesName[cookieId];

            if (regex.test(cookieName)) {
                deleteCookie(cookieName);
            }
        }
    }
}

var deleteCookie = function (cookieName) {
    document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/;';
    document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/; domain=.' + location.hostname + ';';
    document.cookie = cookieName + '=; expires=Thu, 01 Jan 2000 00:00:00 GMT; path=/; domain=.' + location.hostname.split('.').slice(-2).join('.') + ';';
}

var getAllCookiesName = function () {
    return document.cookie.split(";")
        .map(test => test.split("=")[0].trim());
}
