module Internal.CookiesRegulationModal exposing (view)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, b, div, h3, h4, p, text)
import Html.Attributes exposing (class, href, id, style, tabindex, target)
import Html.Events as Events exposing (onClick)
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (..)
import Internal.Helpers exposing (..)
import Internal.Picto as Picto
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    div []
        [ div
            [ class "cookies-regulation-modal fade"
            , class "show" |> attrWhen (model.modalState == ModalOpened)
            , style "height" "0" |> attrWhen (model.modalState == ModalClosed)
            , Events.on "transitionend" (Decode.succeed MsgCloseModal) |> attrWhen (model.modalState == ModalFadeClose)
            , tabindex -1
            ]
            [ div [ class "cookies-regulation-modal-dialog" ]
                [ div [ class "cookies-regulation-modal-content" ]
                    [ modalHeaderView
                    , modalBodyView model
                    , modalFooterView
                    ]
                ]
            ]
        , htmlWhen (model.modalState == ModalOpened) <|
            div [ class "cookies-regulation-modal-backdrop" ] []
        ]



-- Internal


modalHeaderView : Html Msg
modalHeaderView =
    div [ class "cookies-regulation-modal-header" ]
        [ h3 [] [ text "Gérer mes cookies" ]
        , Picto.close [ onClick MsgFadeCloseModal ]
        ]


modalBodyView : Model -> Html Msg
modalBodyView model =
    let
        mandatoryServices =
            model.config.services
                |> Dict.filter (\_ service -> service.mandatory)

        notMandatoryServices =
            model.config.services
                |> Dict.filter (\_ service -> not service.mandatory)
    in
    div
        [ id "cookies-regulation-modal-body"
        , class "cookies-regulation-modal-body"
        , class "cookies-regulation-modal-body-scrollable" |> attrWhen model.modalBodyScrollable
        ]
        [ div [ class "cookies-regulation-modal-body-content" ]
            [ p [] [ text model.config.modal.header ]
            , relatedCompaniesView model
            , cookieDuration
            , a
                [ class "cookies-regulation-privacy-policy"
                , href model.config.privacyPolicy.url
                , target "_blank" |> attrWhen model.config.privacyPolicy.openInNewWindow
                ]
                [ text model.config.privacyPolicy.label ]
            , servicesListView "Cookies nécessitant votre consentement" mandatoryServices
            , servicesListView "Cookies exemptés de consentement" notMandatoryServices
            ]
        ]


modalFooterView : Html Msg
modalFooterView =
    div [ class "cookies-regulation-modal-footer" ]
        [ Button.view { label = "Mémoriser mes choix", type_ = Button.Primary, msg = MsgSave }
        ]


servicesListView : String -> Services -> Html Msg
servicesListView title_ services =
    let
        servicesView =
            services
                |> Dict.map (\_ service -> serviceView service)
                |> Dict.values
    in
    div []
        ([ h4 [] [ text title_ ]
         ]
            ++ servicesView
        )


serviceView : Service -> Html Msg
serviceView serviceConfiguration =
    let
        description =
            Maybe.withDefault "" serviceConfiguration.description
    in
    div [ class "cookies-regulation-service" ]
        [ div [ class "cookies-regulation-service-status" ]
            [ Picto.padlock |> htmlWhenNot serviceConfiguration.mandatory
            ]
        , div []
            [ div [] [ text serviceConfiguration.name ]
            , htmlWhenNotEmpty description (\message -> div [ class "cookies-regulation-service-description" ] [ text message ])
            , div [ class "cookies-regulation-service-conservation" ]
                [ b [] [ text "Conservation :" ]
                , text serviceConfiguration.conservation
                ]
            ]
        ]


relatedCompaniesView : Model -> Html msg
relatedCompaniesView model =
    div [ class "cookies-regulation-information" ]
        [ Picto.share
        , div [] (relatedCompaniesLabel model)
        ]


cookieDuration : Html msg
cookieDuration =
    div [ class "cookies-regulation-information" ]
        [ Picto.clock
        , div []
            [ div [] [ text "Nous conservons vos choix pendant 6 mois." ]
            , div [] [ text "Vous pouvez changer d’avis à tout moment en cliquant sur le bouton « Cookies » au bas du site." ]
            ]
        ]
