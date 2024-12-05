module Internal.Translations exposing (Locale(..), banner_close, banner_cookies_button_details, banner_cookies_modal_button_no_consent_close, banner_cookies_no_consent, banner_cookies_regulation, banner_customise, modal_accept_all, modal_close, modal_cookie_conservation, modal_cookies_with_agreement, modal_cookies_without_agreement, modal_reject_all, modal_related_companies_link_label, modal_related_companies_use_cookies, modal_save_my_choices, modal_title, modal_user_choices_change, modal_user_choices_conservation_duration)


type Locale
    = En
    | Fr


banner_cookies_regulation : Locale -> String
banner_cookies_regulation locale =
    case locale of
        En ->
            "Check the cookies we use for this site..."

        Fr ->
            "Contrôlez les cookies que nous utilisons pour ce site..."


modal_close : Locale -> String
modal_close locale =
    case locale of
        En ->
            "Close modal"

        Fr ->
            "Fermer la modale des cookies"


banner_close : Locale -> String
banner_close locale =
    case locale of
        En ->
            "Close banner"

        Fr ->
            "Fermer le bandeau des cookies"


banner_customise : Locale -> String
banner_customise locale =
    case locale of
        En ->
            "Customise"

        Fr ->
            "Personnaliser"


modal_accept_all : Locale -> String
modal_accept_all locale =
    case locale of
        En ->
            "Accept all"

        Fr ->
            "Tout accepter"


modal_cookie_conservation : Locale -> String
modal_cookie_conservation locale =
    case locale of
        En ->
            "Conservation :"

        Fr ->
            "Conservation :"


modal_cookies_with_agreement : Locale -> String
modal_cookies_with_agreement locale =
    case locale of
        En ->
            "Cookies requiring your consent"

        Fr ->
            "Cookies nécessitant votre consentement"


modal_cookies_without_agreement : Locale -> String
modal_cookies_without_agreement locale =
    case locale of
        En ->
            "Cookies exempt from consent"

        Fr ->
            "Gérer mes cookies"


modal_reject_all : Locale -> String
modal_reject_all locale =
    case locale of
        En ->
            "Refuse all"

        Fr ->
            "Tout refuser"


modal_related_companies_link_label : Int -> Locale -> String
modal_related_companies_link_label count locale =
    case ( count, locale ) of
        ( 0, En ) ->
            "No third party companies"

        ( 0, Fr ) ->
            "Aucune société tierce"

        ( 1, En ) ->
            "A third party company"

        ( 1, Fr ) ->
            "Une société tierce"

        ( _, En ) ->
            String.fromInt count ++ " third-party companies"

        ( _, Fr ) ->
            String.fromInt count ++ " sociétés tierces"


modal_related_companies_use_cookies : Int -> { website : String } -> Locale -> String
modal_related_companies_use_cookies count data locale =
    case ( count, locale ) of
        ( 0, En ) ->
            "uses cookies on " ++ data.website

        ( 0, Fr ) ->
            "n’utilise des cookies sur " ++ data.website

        ( 1, En ) ->
            "uses cookie(s) on " ++ data.website

        ( 1, Fr ) ->
            "utilise un/des cookie/s sur " ++ data.website

        ( _, En ) ->
            "use cookies on " ++ data.website

        ( _, Fr ) ->
            "utilisent des cookies sur " ++ data.website


modal_save_my_choices : Locale -> String
modal_save_my_choices locale =
    case locale of
        En ->
            "Save my choices"

        Fr ->
            "Mémoriser mes choix"


modal_title : Locale -> String
modal_title locale =
    case locale of
        En ->
            "Manage my cookies"

        Fr ->
            "Gérer mes cookies"


modal_user_choices_change : Locale -> String
modal_user_choices_change locale =
    case locale of
        En ->
            "You can change your mind at any time by clicking on the « Cookies » button at the bottom of the site."

        Fr ->
            "Vous pouvez changer d’avis à tout moment en cliquant sur le bouton « Cookies » au bas du site."


modal_user_choices_conservation_duration : Locale -> String
modal_user_choices_conservation_duration locale =
    case locale of
        En ->
            "We keep your choices for 6 months."

        Fr ->
            "Nous conservons vos choix pendant 6 mois."


banner_cookies_no_consent : Locale -> String
banner_cookies_no_consent locale =
    case locale of
        En ->
            "Your privacy is important ! We do not use any cookie requiring your consent."

        Fr ->
            "Votre vie privée nous importe ! Nous n’utilisons aucun cookie indiscret nécessitant votre consentement."


banner_cookies_button_details : Locale -> String
banner_cookies_button_details locale =
    case locale of
        En ->
            "Cookies details"

        Fr ->
            "Détails des cookies"


banner_cookies_modal_button_no_consent_close : Locale -> String
banner_cookies_modal_button_no_consent_close locale =
    case locale of
        En ->
            "Close"

        Fr ->
            "Fermer"
