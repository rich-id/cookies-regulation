window.CookiesRegulation = require('../js/cookies-regulation');

CookiesRegulation.init(
    {
        website: 'Cookies Regulation',
        privacyPolicy: {
            url:             'https://example.com/privacy',
            label:           'Privacy Policy',
            openInNewWindow: true,
        },
        modal: {
            header:                           'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras hendrerit, velit vitae accumsan pellentesque, sapien arcu gravida nibh, at accumsan nulla sapien sed magna. Integer sed sem dolor. Pellentesque feugiat, quam quis dapibus vehicula, risus morbi.',
            headerWithoutConsent:             'Lorem ipsum no consent',
            relatedCompaniesCount:            5,
            relatedCompaniesPrivacyPolicyUrl: 'https://example.com/companies'
        },
        services: {
          googleTagManager: {
            name:         'Google Tag Manager',
            description:  'Tag management system',
            conservation: '6 months.',
            service:      'googleTagManager',
            options:      {id: 'GTM-TEST'},
          },
          cookieTest1: {
            name:         'Test Cookie',
            description:  'Test description.',
            conservation: '1 year.',
            mandatory:    false,
            initializationCallback: function () {
              console.log('initializationCallback cookieTest1');
              alert('Cookie de test');
            }
          },
          cookieTest2: {
            name:         'Other test cookie',
            description:  null,
            conservation: '6 months.',
            mandatory:    true,
          },
          cookieTest3: {
            name:         'Other test cookie 2',
            description:  null,
            conservation: 'until you log out.',
            mandatory:    true,
          },
          matomo: {
            name:         'Matomo',
            description:  'Matomo description',
            conservation: '',
            service:      'matomo',
            enabledByDefault: true,
            options:      {url: 'test.test', siteId: '1'},
          },
        },
        locale: 'en',
        decisionLogCallback: function (decision) {
            console.log('decisionLogCallback');
            alert(decision)
        }
    }
);
