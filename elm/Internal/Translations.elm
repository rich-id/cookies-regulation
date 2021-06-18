module Internal.Translations exposing (Local(..), bandeau_cookies_regulation, modal_accept_all, modal_cookie_conservation, modal_cookies_with_agreement, modal_cookies_without_agreement, modal_reject_all, modal_related_companies_link_label, modal_related_companies_use_cookies, modal_save_my_choices, modal_title, modal_user_choices_change, modal_user_choices_conservation_duration)


type Local
    = En
    | Fr


bandeau_cookies_regulation : Local -> String
bandeau_cookies_regulation local =
    case local of
        En ->
            "Check the cookies we use for this site..."

        Fr ->
            "Contrôlez les cookies que nous utilisons pour ce site..."


modal_accept_all : Local -> String
modal_accept_all local =
    case local of
        En ->
            "Accept all"

        Fr ->
            "Tout accepter"


modal_cookie_conservation : Local -> String
modal_cookie_conservation local =
    case local of
        En ->
            "Conservation :"

        Fr ->
            "Conservation :"


modal_cookies_with_agreement : Local -> String
modal_cookies_with_agreement local =
    case local of
        En ->
            "Cookies requiring your consent"

        Fr ->
            "Cookies nécessitant votre consentement"


modal_cookies_without_agreement : Local -> String
modal_cookies_without_agreement local =
    case local of
        En ->
            "Cookies exempt from consent"

        Fr ->
            "Gérer mes cookies"


modal_reject_all : Local -> String
modal_reject_all local =
    case local of
        En ->
            "Refuse all"

        Fr ->
            "Tout refuser"


modal_related_companies_link_label : Int -> Local -> String
modal_related_companies_link_label count local =
    case ( count, local ) of
        ( 0, En ) ->
            "No third party company"

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


modal_related_companies_use_cookies : Int -> { website : String } -> Local -> String
modal_related_companies_use_cookies count data local =
    case ( count, local ) of
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


modal_save_my_choices : Local -> String
modal_save_my_choices local =
    case local of
        En ->
            "Save my choices"

        Fr ->
            "Mémoriser mes choix"


modal_title : Local -> String
modal_title local =
    case local of
        En ->
            "Manage my cookies"

        Fr ->
            "Gérer mes cookies"


modal_user_choices_change : Local -> String
modal_user_choices_change local =
    case local of
        En ->
            "You can change your mind at any time by clicking on the « Cookies » button at the bottom of the site."

        Fr ->
            "Vous pouvez changer d’avis à tout moment en cliquant sur le bouton « Cookies » au bas du site."


modal_user_choices_conservation_duration : Local -> String
modal_user_choices_conservation_duration local =
    case local of
        En ->
            "We keep your choices for 6 months."

        Fr ->
            "Nous conservons vos choix pendant 6 mois."
