window.cookiesRegulationServices = {};

//  Google Tag Manager
window.cookiesRegulationServices.googleTagManager = {
    requiredOptions: ['id'],
    callback: function (options) {
        window.dataLayer = window.dataLayer || [];
        window.dataLayer.push({
            'gtm.start': new Date().getTime(),
            event: 'gtm.js'
        });

        var scripts = document.getElementsByTagName('script')[0];

        var googleTagManagerScript = document.createElement('script');
        googleTagManagerScript.async = true;
        googleTagManagerScript.src ='https://www.googletagmanager.com/gtm.js?id=' + options.id;

        scripts.parentNode.insertBefore(googleTagManagerScript, scripts);
    }
};
