window.Elm = require('./../elm/CookiesRegulation.elm').Elm;

window.getReferencesCookie = function () {
    var cookieArr = document.cookie.split(";");

    for(var i = 0; i < cookieArr.length; i++) {
        var cookiePair = cookieArr[i].split("=");

        if (cookiePair[0].trim() === 'cookie_preferences' ) {
            return decodeURIComponent(cookiePair[1]);
        }
    }

    return null;
};

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
        window.cookiesRegulationBlock.ports.openModal.send(null);
    },

    setPreferences: function(preferences) {
        const expirationDate = Date.now();
        expirationDate.setMonth(expirationDate.getMonth + 6);
    },

    getPreferences: function() {
        var cookie = window.getReferencesCookie();
        console.log(cookie);
    }
}
