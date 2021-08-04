window.cookiesRegulationServices = {};

function insertScript(url) {
    const script = document.createElement('script');
    script.async = true;
    script.src   = url;

    const head = document.getElementsByTagName('head')[0];
    head.appendChild(script);
}

// Google Tag Manager
window.cookiesRegulationServices.googleTagManager = {
    requiredOptions: ['id'],
    cookiesIdentifiers: ['^ga.*$', '^_ga.*$', '^_gc.*$', '^_gi.*$', '^_hj.*$', '^__utma.*$', '^__utmb.*$', '^__utmc.*$', '^__utmt.*$', '^__utmz.*$', '^__gads.*$'],
    callback: function (options) {
        window.dataLayer = window.dataLayer || [];
        window.dataLayer.push({
            'gtm.start': new Date().getTime(),
            'event':     'gtm.js'
        });

        insertScript('https://www.googletagmanager.com/gtm.js?id=' + options.id);
    }
};

// Google Analytics
window.cookiesRegulationServices.googleAnalytics = {
    requiredOptions: ['id'],
    cookiesIdentifiers: ['^ga.*$', '^_ga.*$', '^_gc.*$', '^_gi.*$', '^_hj.*$', '^__utma.*$', '^__utmb.*$', '^__utmc.*$', '^__utmt.*$', '^__utmz.*$', '^__gads.*$'],
    callback: function (options) {
        window.dataLayer = window.dataLayer || [];
        window.dataLayer.push({
            js:     new Date(),
            config: options.id,
        });

        insertScript('https://www.googletagmanager.com/gtag/js?id=' + options.id);
    }
};

// Hotjar
window.cookiesRegulationServices.hotjar = {
    requiredOptions: ['id'],
    cookiesIdentifiers: ['hjClosedSurveyInvites', '^_hj[a-zA-Z0-9]*$'],
    callback: function (options) {
        window._hjSettings = {
            hjid: options.id,
            hjsv: 6,
        };

        window.hj = window.hj || function() {
            (window.hj.q = window.hj.q || []).push(arguments)
        };

        const url = 'https://static.hotjar.com/c/hotjar-'
            + window._hjSettings.hjid
            + '.js?sv='
            + window._hjSettings.hjsv;

        insertScript(url);
    }
};
