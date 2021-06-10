module Internal.Helpers exposing (attrWhen, htmlWhen, htmlWhenNot, htmlWhenNotEmpty, relatedCompaniesLabel)

import Html exposing (Attribute, Html, a, text)
import Html.Attributes exposing (class, href)
import Internal.CookiesRegulationData exposing (Model)


attrWhen : Bool -> Attribute msg -> Attribute msg
attrWhen predicate attr =
    if predicate then
        attr

    else
        class ""


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
            if model.modal.relatedCompaniesCount < 0 then
                0

            else
                model.modal.relatedCompaniesCount
    in
    case nbCompanies of
        0 ->
            [ a [ href model.modal.relatedCompaniesPrivacyPolicyUrl ] [ text "Aucune société tierce" ]
            , text ("n’utilise des cookies sur " ++ model.website)
            ]

        1 ->
            [ a [ href model.modal.relatedCompaniesPrivacyPolicyUrl ] [ text "Une société tierce" ]
            , text ("utilise un/des cookie/s sur " ++ model.website)
            ]

        _ ->
            [ a [ href model.modal.relatedCompaniesPrivacyPolicyUrl ] [ text (String.fromInt nbCompanies ++ " sociétés tierces") ]
            , text ("utilisent des cookies sur " ++ model.website)
            ]
