module Internal.Helpers exposing (attrWhen, attrWhenNot, htmlWhen, htmlWhenNot, htmlWhenNotEmpty, relatedCompaniesLabel)

import Html exposing (Attribute, Html, a, text)
import Html.Attributes exposing (class, href)
import Internal.CookiesRegulationData exposing (Model)


attrWhen : Bool -> Attribute msg -> Attribute msg
attrWhen predicate attr =
    if predicate then
        attr

    else
        class ""


attrWhenNot : Bool -> Attribute msg -> Attribute msg
attrWhenNot predicate =
    attrWhen (not predicate)


htmlWhen : Bool -> Html msg -> Html msg
htmlWhen predicate html_ =
    if predicate then
        html_

    else
        text ""


htmlWhenNot : Bool -> Html msg -> Html msg
htmlWhenNot predicate =
    htmlWhen (not predicate)


htmlWhenNotEmpty : String -> (String -> Html msg) -> Html msg
htmlWhenNotEmpty message view_ =
    if message == "" then
        text ""

    else
        view_ message


relatedCompaniesLabel : Model -> List (Html msg)
relatedCompaniesLabel model =
    let
        nbCompanies =
            if model.config.modal.relatedCompaniesCount < 0 then
                0

            else
                model.config.modal.relatedCompaniesCount
    in
    case nbCompanies of
        0 ->
            [ a [ href model.config.modal.relatedCompaniesPrivacyPolicyUrl ] [ text "Aucune société tierce" ]
            , text ("n’utilise des cookies sur " ++ model.config.website)
            ]

        1 ->
            [ a [ href model.config.modal.relatedCompaniesPrivacyPolicyUrl ] [ text "Une société tierce" ]
            , text ("utilise un/des cookie/s sur " ++ model.config.website)
            ]

        _ ->
            [ a [ href model.config.modal.relatedCompaniesPrivacyPolicyUrl ] [ text (String.fromInt nbCompanies ++ " sociétés tierces") ]
            , text ("utilisent des cookies sur " ++ model.config.website)
            ]
