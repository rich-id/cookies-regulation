module Internal.Helpers exposing (attrWhen, attrWhenNot, buildPreferencesForSave, filterMandatoryServices, filterNotMandatoryServices, getEnabledNotMandatoryServices, getEnabledNotMandatoryServicesByPreferences, getRejectedNotMandatoryServices, hasAcceptationChange, hasRejectedService, htmlJust, htmlWhen, htmlWhenNot, htmlWhenNotEmpty, isSerciceEnabledByPreferences, relatedCompaniesLabel, updateService)

import Dict
import Html exposing (Attribute, Html, a, text)
import Html.Attributes exposing (class, href)
import Internal.CookiesRegulationData exposing (Model, Preferences, Service, ServiceId, Services)
import Internal.Translations as Trans


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


htmlJust : Maybe a -> (a -> Html msg) -> Html msg
htmlJust maybeA html_ =
    case maybeA of
        Just a ->
            html_ a

        Nothing ->
            text ""


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


buildPreferencesForSave : Model -> Preferences
buildPreferencesForSave model =
    model.notMandatoryServices
        |> Dict.map (\serviceId service -> ( serviceId, service.enabled ))
        |> Dict.values

filterMandatoryServices : Services -> Services
filterMandatoryServices services =
    Dict.filter (\_ service -> service.mandatory) services


filterNotMandatoryServices : Services -> Services
filterNotMandatoryServices services =
    Dict.filter (\_ service -> not service.mandatory) services


getEnabledNotMandatoryServicesByPreferences : Preferences -> Services -> List ServiceId
getEnabledNotMandatoryServicesByPreferences preferences notMandatoryServices =
    preferences
        |> List.filterMap
            (\( serviceId, isEnabled ) ->
                if isEnabled && Dict.member serviceId notMandatoryServices then
                    Just serviceId

                else
                    Nothing
            )


getEnabledNotMandatoryServices : Services -> List ServiceId
getEnabledNotMandatoryServices notMandatoryServices =
    notMandatoryServices
        |> Dict.values
        |> List.filter .enabled
        |> List.map .id


getRejectedNotMandatoryServices : Services -> List ServiceId
getRejectedNotMandatoryServices notMandatoryServices =
    notMandatoryServices
        |> Dict.values
        |> List.filter (not << .enabled)
        |> List.map .id


hasAcceptationChange : Model -> Bool
hasAcceptationChange model =
    (model.notMandatoryServices
        |> Dict.filter (\_ service -> service.enabled)
        |> Dict.keys
    )
        /= model.enabledNotMandatoryServices


hasRejectedService : Model -> Bool
hasRejectedService model =
    model.notMandatoryServices
        |> getRejectedNotMandatoryServices
        |> List.filter (\serviceId -> List.member serviceId model.enabledNotMandatoryServices)
        |> List.isEmpty
        |> not


isSerciceEnabledByPreferences : Preferences -> ServiceId -> Bool
isSerciceEnabledByPreferences preferences serviceId =
    preferences
        |> List.filterMap
            (\( key, value ) ->
                if key == serviceId then
                    Just value

                else
                    Nothing
            )
        |> List.head
        |> Maybe.withDefault False


relatedCompaniesLabel : Model -> List (Html msg)
relatedCompaniesLabel model =
    let
        nbCompanies =
            if model.modal.relatedCompaniesCount < 0 then
                0

            else
                model.modal.relatedCompaniesCount
    in
    [ a [ href model.modal.relatedCompaniesPrivacyPolicyUrl ] [ text (Trans.modal_related_companies_link_label nbCompanies model.locale) ]
    , text (Trans.modal_related_companies_use_cookies nbCompanies { website = model.website } model.locale)
    ]
