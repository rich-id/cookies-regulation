module Internal.CookiesRegulationModal exposing (view)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, b, div, h3, h4, p, span, text)
import Html.Attributes exposing (class, href, id, style, tabindex, target)
import Html.Events as Events exposing (onClick)
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (..)
import Internal.Helpers exposing (..)
import Internal.Picto as Picto
import Internal.SwitchCheckbox as SwitchCheckbox
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
                    , modalFooterView model
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
        , Picto.close [ onClick MsgCloseModal ]
        ]


modalBodyView : Model -> Html Msg
modalBodyView model =
    div
        [ id "cookies-regulation-modal-body"
        , class "cookies-regulation-modal-body"
        , class "cookies-regulation-modal-body-scrollable" |> attrWhen model.modalBodyScrollable
        ]
        [ div [ class "cookies-regulation-modal-body-content" ]
            [ div [ class "cookies-regulation-modal-body-content-top" ]
                [ p [ class "cookies-regulation-modal-body-content-header" ] [ text model.modal.header ]
                , relatedCompaniesView model
                , cookieDurationView
                , privacyPolicyLinkView model
                , globalActionButtonsView
                ]
            , servicesListView "Cookies nécessitant votre consentement" model.mandatoryServices
            , servicesListView "Cookies exemptés de consentement" model.notMandatoryServices
            ]
        ]


modalFooterView : Model -> Html Msg
modalFooterView model =
    div [ class "cookies-regulation-modal-footer" ]
        [ Button.view { label = "Mémoriser mes choix", type_ = Button.Primary, disabled = not (hasAcceptationChange model), msg = MsgSave }
        ]


servicesListView : String -> Services -> Html Msg
servicesListView title_ services =
    let
        servicesView =
            services
                |> Dict.values
                |> List.sortBy .name
                |> List.map (\service -> serviceView service)
    in
    div [ class "cookies-regulation-services" ]
        ([ h4 [] [ text title_ ]
         ]
            ++ servicesView
        )


serviceView : Service -> Html Msg
serviceView service =
    let
        description =
            Maybe.withDefault "" service.description
    in
    div [ class "cookies-regulation-service" ]
        [ div [ class "cookies-regulation-service-status" ]
            [ htmlWhenNot service.mandatory <| Picto.padlock
            , htmlWhen service.mandatory <|
                SwitchCheckbox.view
                    { id = service.id
                    , isChecked = service.enabled
                    , msg_ = MsgUpdateServiceStatus service.id
                    }
            ]
        , div []
            [ div [] [ span [ onClick (MsgUpdateServiceStatus service.id) |> attrWhen service.mandatory ] [ text service.name ] ]
            , htmlWhenNotEmpty description (\message -> div [ class "cookies-regulation-service-description" ] [ text message ])
            , div [ class "cookies-regulation-service-conservation" ]
                [ b [] [ text "Conservation :" ]
                , text service.conservation
                ]
            ]
        ]


relatedCompaniesView : Model -> Html msg
relatedCompaniesView model =
    div [ class "cookies-regulation-information" ]
        [ Picto.share
        , div [] (relatedCompaniesLabel model)
        ]


cookieDurationView : Html msg
cookieDurationView =
    div [ class "cookies-regulation-information" ]
        [ Picto.clock
        , div []
            [ div [] [ text "Nous conservons vos choix pendant 6 mois." ]
            , div [] [ text "Vous pouvez changer d’avis à tout moment en cliquant sur le bouton « Cookies » au bas du site." ]
            ]
        ]


privacyPolicyLinkView : Model -> Html msg
privacyPolicyLinkView model =
    a
        [ class "cookies-regulation-privacy-policy"
        , href model.privacyPolicy.url
        , target "_blank" |> attrWhen model.privacyPolicy.openInNewWindow
        ]
        [ text model.privacyPolicy.label ]


globalActionButtonsView : Html Msg
globalActionButtonsView =
    div [ class "cookies-regulation-modal-body-content-actions" ]
        [ Button.view { label = "Tout accepter", type_ = Button.Primary, disabled = False, msg = MsgModalAcceptAll }
        , Button.view { label = "Tout refuser", type_ = Button.Primary, disabled = False, msg = MsgModalRejectAll }
        ]
