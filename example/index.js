window.CookieRegulation = require('../js/cookies-regulation');

CookieRegulation.init(
    {
        website: 'Cookies Regulations',
        privacyPolicy: {
            url: 'https://example.com/privacy',
            bandeauLabel: 'Politique de confidentialité',
            modalLabel: 'Consultez notre politique de confidentialité',
            openInNewWindow: true,
        },
        services: {
            googleAnalytics: {
                name:         'Google Analytics',
                description:  'Outil de statistiques d’audience et d’analyse de navigation.',
                conservation: '2 ans',
                mandatory:    true,
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
