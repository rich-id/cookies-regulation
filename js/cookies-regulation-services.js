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
        window.gtag = function gtag() {
            window.dataLayer.push(arguments);
        };

        const additionalData = {anonymize_ip: false};

        if (options.anonymize_ip === true) {
            additionalData.anonymize_ip = true;
        }

        insertScript('https://www.googletagmanager.com/gtag/js?id=' + options.id);
        gtag('js', new Date());
        gtag('config', options.id, additionalData);
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

// Matomo
window.cookiesRegulationServices.matomo = {
    requiredOptions: ['url', 'siteId'],
    cookiesIdentifiers: [],
    callback: function (options) {
        var u = '//' + options.url + '/';

        window._paq = window._paq || [];
        window._paq.push(['trackPageView']);
        window._paq.push(['enableLinkTracking']);
        window._paq.push(['setTrackerUrl', u + 'matomo.php']);
        window._paq.push(['setSiteId', options.siteId]);

        insertScript(u + 'matomo.js');
    }
};
