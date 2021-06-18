module Internal.CookiesRegulationModal exposing (view)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, b, div, p, span, text)
import Html.Attributes exposing (class, href, id, style, tabindex, target)
import Html.Events as Events exposing (onClick)
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (..)
import Internal.Helpers exposing (..)
import Internal.Picto as Picto
import Internal.SwitchCheckbox as SwitchCheckbox
import Internal.Translations as Trans exposing (Local)
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    div []
        [ div
            [ class "cookies-regulation-modal"
            , class "cookies-regulation-show" |> attrWhen (model.modalState == ModalOpened)
            , style "height" "0" |> attrWhen (model.modalState == ModalClosed)
            , Events.on "transitionend" (Decode.succeed InternalMsgCloseModal) |> attrWhen (model.modalState == ModalFadeClose)
            , tabindex -1
            ]
            [ div [ class "cookies-regulation-modal-dialog" ]
                [ div [ class "cookies-regulation-modal-content" ]
                    [ modalHeaderView model
                    , modalBodyView model
                    , modalFooterView model
                    ]
                ]
            ]
        , htmlWhen (model.modalState == ModalOpened) <|
            div [ class "cookies-regulation-modal-backdrop" ] []
        ]



-- Internal


modalHeaderView : Model -> Html Msg
modalHeaderView model =
    div [ class "cookies-regulation-modal-header" ]
        [ div [ class "cookies-regulation-h3" ] [ text (Trans.modal_title model.local) ]
        , htmlWhenNot model.needUserAction <|
            Picto.close [ onClick MsgCloseModal ]
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
                , cookieDurationView model
                , privacyPolicyLinkView model
                , globalActionButtonsView model
                ]
            , servicesListView model.local (Trans.modal_cookies_with_agreement model.local) model.mandatoryServices
            , servicesListView model.local (Trans.modal_cookies_without_agreement model.local) model.notMandatoryServices
            ]
        ]


modalFooterView : Model -> Html Msg
modalFooterView model =
    div [ class "cookies-regulation-modal-footer" ]
        [ Button.view
            { label = Trans.modal_save_my_choices model.local
            , type_ = Button.Primary
            , disabled = not (hasAcceptationChange model) && not model.needUserAction
            , msg = MsgSave
            }
        ]


servicesListView : Local -> String -> Services -> Html Msg
servicesListView local title_ services =
    let
        servicesView =
            services
                |> Dict.values
                |> List.sortBy .name
                |> List.map (\service -> serviceView local service)
    in
    div [ class "cookies-regulation-services" ]
        ([ div [ class "cookies-regulation-h4" ] [ text title_ ]
         ]
            ++ servicesView
        )


serviceView : Local -> Service -> Html Msg
serviceView local service =
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
                [ b [] [ text (Trans.modal_cookie_conservation local) ]
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


cookieDurationView : Model -> Html msg
cookieDurationView model =
    div [ class "cookies-regulation-information" ]
        [ Picto.clock
        , div []
            [ div [] [ text (Trans.modal_user_choices_conservation_duration model.local) ]
            , div [] [ text (Trans.modal_user_choices_change model.local) ]
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


globalActionButtonsView : Model -> Html Msg
globalActionButtonsView model =
    div [ class "cookies-regulation-modal-body-content-actions" ]
        [ Button.view { label = Trans.modal_accept_all model.local, type_ = Button.Primary, disabled = False, msg = MsgModalAcceptAll }
        , Button.view { label = Trans.modal_reject_all model.local, type_ = Button.Primary, disabled = False, msg = MsgModalRejectAll }
        ]
