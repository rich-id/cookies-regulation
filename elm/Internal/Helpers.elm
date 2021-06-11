module Internal.Helpers exposing (attrWhen, buildAcceptAllPreferences, buildRejectAllPreferences, filterMandatoryServices, filterNotMandatoryServices, getEnabledMandatoryServices, hasAcceptationChange, htmlWhen, htmlWhenNot, htmlWhenNotEmpty, relatedCompaniesLabel, updateService)

import Dict
import Html exposing (Attribute, Html, a, text)
import Html.Attributes exposing (class, href)
import Internal.CookiesRegulationData exposing (Model, Preferences, Service, ServiceId, Services)


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


updateService : Services -> String -> (Service -> Service) -> Services
updateService services serviceId updater =
    services
        |> Dict.map
            (\key service ->
                if key == serviceId then
                    updater service

                else
                    service
            )


buildAcceptAllPreferences : Model -> Preferences
buildAcceptAllPreferences model =
    model.mandatoryServices
        |> Dict.map (\serviceId _ -> ( serviceId, True ))
        |> Dict.values


buildRejectAllPreferences : Model -> Preferences
buildRejectAllPreferences model =
    model.mandatoryServices
        |> Dict.map (\serviceId _ -> ( serviceId, False ))
        |> Dict.values


filterMandatoryServices : Services -> Services
filterMandatoryServices services =
    Dict.filter (\_ service -> service.mandatory) services


filterNotMandatoryServices : Services -> Services
filterNotMandatoryServices services =
    Dict.filter (\_ service -> not service.mandatory) services


getEnabledMandatoryServices : Preferences -> Services -> List ServiceId
getEnabledMandatoryServices preferences mandatoryServices =
    preferences
        |> List.filterMap
            (\( serviceId, isEnabled ) ->
                if isEnabled && Dict.member serviceId mandatoryServices then
                    Just serviceId

                else
                    Nothing
            )


hasAcceptationChange : Model -> Bool
hasAcceptationChange model =
    (model.mandatoryServices
        |> Dict.filter (\_ service -> service.enabled)
        |> Dict.keys
    )
        /= model.enabledMandatoryServices


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
