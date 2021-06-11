require('./cookies-regulation-services');

window.CookiesRegulationElm = require('./../elm/CookiesRegulation.elm').Elm.CookiesRegulation;

module.exports = {
    init: function (config) {
        buildAndStoreConfiguration(config);

        let container = document.createElement('div');
        document.body.appendChild(container);

        const references = this.getPreferences();

        window.cookiesRegulationBlock = window.CookiesRegulationElm.init({
            node: container,
            flags: {
                preferences: references,
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

    removeService: function (serviceName) {
        const service = window.cookiesRegulationConfig.services[serviceName];

        if (!service) {
            console.error('Failed to get the service "' + serviceName + '". Please check your configuration.');
            return;
        }

        // Supprimer les cookies dont les domaines sont présentés dans la liste
        service.cookieDomains.forEach(function (domain) {
            browser.cookies.get({url: domain}).then(function (cookie) {
                if (!cookie) {
                    return;
                }

                browser.cookies.remove(cookie);
            });
        });
    },

    openModal: function () {
        window.cookiesRegulationBlock.ports.openModal.send(null);
    },

    setPreferences: function(preferences) {
        var encodedPreferences = encodeCookiePreferencesData(preferences);

        if (encodedPreferences === null) {
            return;
        }

        const expirationDate = new Date();
        expirationDate.setMonth(expirationDate.getMonth() + 6);

        const expires = "expires=" + expirationDate.toUTCString();
        const secure = location.protocol === 'https:' ? '; Secure' : '';

        document.cookie = 'cookie_preferences=' + encodedPreferences + '; ' + expires + '; path=/;' + secure + '; samesite=lax';
    },

    getPreferences: function() {
        var cookie = getReferencesCookie();

        if (cookie === null) {
            return [];
        }
        return decodeCookiePreferencesData(cookie);
    }
}

var getReferencesCookie = function () {
    var cookieArr = document.cookie.split(";");

    for(var i = 0; i < cookieArr.length; i++) {
        var cookiePair = cookieArr[i].split("=");

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
    for (serviceId in config.services) {
        let service = config.services[serviceId].service;
        var options = config.services[serviceId].options ?? {};

        if (typeof service === 'undefined') {
            continue;
        }

        if (typeof window.cookieRegulationServices[service] === 'undefined') {
            console.log('No auto-configured service exists with the ' + service + ' id');
            delete config.services[serviceId];
            continue;
        }

        var definedOptions = [];

        for (option in options) {
            definedOptions.push(option);
        }

        var requiredOptions = window.cookieRegulationServices[service].requiredOptions;
        var hasMissingOption = false;

        for(var i = 0; i < requiredOptions.length; i++) {
            var requiredOption = requiredOptions[i];

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
                window.cookieRegulationServices[service].callback(options);
            };

            delete config.services[serviceId].service;
            delete config.services[serviceId].options;
        }
    }

    window.cookiesRegulationConfig = config;
};
