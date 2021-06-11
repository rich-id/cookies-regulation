window.CookieRegulation = require('../js/cookies-regulation');

CookieRegulation.init(
    {
        website: 'Cookies Regulation',
        privacyPolicy: {
            url: 'https://example.com/privacy',
            label: 'Politique de confidentialité',
            openInNewWindow: true,
        },
        modal: {
            header: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras hendrerit, velit vitae accumsan pellentesque, sapien arcu gravida nibh, at accumsan nulla sapien sed magna. Integer sed sem dolor. Pellentesque feugiat, quam quis dapibus vehicula, risus morbi.',
            relatedCompaniesCount: 5,
            relatedCompaniesPrivacyPolicyUrl: ''
        },
        services: {
            googleAnalytics: {
                name:         'Google Analytics',
                description:  'Outil de statistiques d’audience et d’analyse de navigation.',
                conservation: '2 ans',
                mandatory:    true,
                initializationCallback: function () {
                    window.dataLayer = window.dataLayer || [];
                    window.dataLayer.push({
                        'gtm.start': new Date().getTime(),
                        event: 'gtm.js'
                    });

                    var scripts = document.getElementsByTagName('script')[0];

                    var googleTagManagerScript = document.createElement('script');
                    googleTagManagerScript.async = true;
                    googleTagManagerScript.src ='https://www.googletagmanager.com/gtm.js?id=GTM-TL7WDMC';

                    scripts.parentNode.insertBefore(googleTagManagerScript, scripts);
                }
            },
            hotjar: {
                name:         'Hotjar',
                description:  'Outil d’analyse comportementale et d’enregistrement anonyme du comportement des utilisateurs et utilisatrices.',
                conservation: '1 an',
                mandatory:    true,
            },
            cookie: {
                name:         'Conservation de vos choix de cookies',
                description:  'Outil d’analyse comportementale et d’enregistrement anonyme du comportement des utilisateurs et utilisatrices.',
                conservation: '6 mois',
                mandatory:    false,
            },
            login: {
                name:         'Mémorisation de votre identifiant de session, afin de maintenir votre connexion pendant la navigation',
                description:  null,
                conservation: 'jusqu’à votre déconnexion. 4 heures maximum',
                mandatory:    false,
            },
            location: {
                name:         'Mémorisation du lieu utilisé pour la recherche de formations.',
                description:  null,
                conservation: 'pendant votre navigation',
                mandatory:    false,
            }
        }
    }
);
