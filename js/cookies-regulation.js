window.Elm = require('./../elm/CookiesRegulation.elm').Elm;

module.exports = {
    init: function (config) {
        window.cookiesRegulationConfig = config;
        let container = document.createElement('div');
        document.body.appendChild(container);

        window.cookiesRegulationBlock = window.Elm.CookiesRegulation.init({
            node: container,
            flags: {
                preferences: this.getPreferences(),
                config: config
            },
        });
        //
        // window.cookiesRegulationBlock.ports.initializeService.subscribe(this.initializeService);
        // window.cookiesRegulationBlock.ports.setPreferences.subscribe(this.setPreferences);
    },

    initializeService: function (serviceName) {
        const service = window.cookiesRegulationConfig.services[serviceName];

        if (!service) {
            console.error('Failed to load the service "' + serviceName + '". Please check your configuration.');
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
        window.cookiesRegulationBlock.ports.openModal.send();
    },

    setPreferences: function(preferences) {
        const expirationDate = Date.now();
        expirationDate.setMonth(expirationDate.getMonth + 6);
    },

    getPreferences: function() {

    }
}
