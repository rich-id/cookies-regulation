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
            relatedCompaniesPrivacyPolicyUrl: 'https://example.com/companies'
        },
        services: {
            googleTagManager: {
                name:         'Google Tag Manager',
                description:  'Système de gestion de balises',
                conservation: '6 mois.',
                service: 'googleTagManager',
                options: {id: 'GTM-TEST'},
            },
            cookieTest1: {
                name:         'Cookie de test',
                description:  'Description de test.',
                conservation: '1 an.',
                mandatory:    true,
                initializationCallback: function () {
                    alert('Cookie de test');
                }
            },
            cookieTest2: {
                name:         'Autre cookie de test 1',
                description:  null,
                conservation: '6 mois.',
                mandatory:    false,
            },
            cookieTest3: {
                name:         'Autre cookie de test 2',
                description:  null,
                conservation: 'jusqu’à votre déconnexion.',
                mandatory:    false,
            }
        }
    }
);
