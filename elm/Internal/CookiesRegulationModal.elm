module Internal.CookiesRegulationModal exposing (view)

import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, b, button, div, p, span, text)
import Html.Attributes exposing (class, href, id, style, tabindex, target)
import Html.Events as Events exposing (onClick)
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (..)
import Internal.Helpers exposing (..)
import Internal.Picto as Picto
import Internal.SwitchCheckbox as SwitchCheckbox
import Internal.Translations as Trans exposing (Locale)
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    div []
        [ div
            [ id "cookies-regulation-modal"
            , class "cookies-regulation-modal"
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
        [ div [ class "cookies-regulation-h3" ] [ text (Trans.modal_title model.locale) ]
        , htmlWhenNot model.needUserAction <|
            button
                [ id "cookies-regulation-close"
                , onClick
                    (if model.isCookiePresent then
                        MsgCloseModal

                     else
                        MsgSave
                    )
                ]
                [ Picto.close []
                ]
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
                [ p [ class "cookies-regulation-modal-body-content-header" ]
                    [ if model.noConsent then
                        text <| model.modal.headerWithoutConsent

                      else
                        text <| model.modal.header
                    ]
                , relatedCompaniesView model
                , htmlWhen (not model.noConsent) <| cookieDurationView model
                , privacyPolicyLinkView model
                , htmlWhen (not model.noConsent) <| globalActionButtonsView model
                ]
            , htmlWhen (not model.noConsent) <| servicesListView model.locale (Trans.modal_cookies_with_agreement model.locale) model.notMandatoryServices
            , servicesListView model.locale (Trans.modal_cookies_without_agreement model.locale) model.mandatoryServices
            ]
        ]


modalFooterView : Model -> Html Msg
modalFooterView model =
    let
        _ =
            Debug.log "test" (not (hasAcceptationChange model) && not model.needUserAction)
    in
    div [ class "cookies-regulation-modal-footer" ]
        [ htmlWhen (not model.noConsent) <|
            Button.view
                { label = Trans.modal_save_my_choices model.locale
                , type_ = Button.Primary
                , disabled = not (hasAcceptationChange model) && not model.needUserAction
                , msg = MsgSave
                }
        , htmlWhen model.noConsent <|
            Button.view
                { label = Trans.banner_cookies_modal_button_no_consent_close model.locale
                , type_ = Button.Primary
                , disabled = False
                , msg =
                    if model.isCookiePresent then
                        MsgCloseModal

                    else
                        MsgSave
                }
        , htmlJust model.lastDecisionMetadata <|
            decisionMetadataView
        ]


servicesListView : Locale -> String -> Services -> Html Msg
servicesListView locale title_ services =
    let
        servicesView =
            services
                |> Dict.values
                |> List.sortBy .name
                |> List.map (\service -> serviceView locale service)
    in
    div [ class "cookies-regulation-services" ]
        ([ div [ class "cookies-regulation-h4" ] [ text title_ ]
         ]
            ++ servicesView
        )


serviceView : Locale -> Service -> Html Msg
serviceView locale service =
    let
        description =
            Maybe.withDefault "" service.description
    in
    div [ class "cookies-regulation-service" ]
        [ div [ class "cookies-regulation-service-status" ]
            [ htmlWhen service.mandatory <| Picto.padlock
            , htmlWhenNot service.mandatory <|
                SwitchCheckbox.view
                    { id = service.id
                    , label = service.name
                    , isChecked = service.enabled
                    , msg_ = MsgUpdateServiceStatus service.id
                    }
            ]
        , div []
            [ div [] [ span [ onClick (MsgUpdateServiceStatus service.id) |> attrWhenNot service.mandatory ] [ text service.name ] ]
            , htmlWhenNotEmpty description (\message -> div [ class "cookies-regulation-service-description" ] [ text message ])
            , htmlWhenNotEmpty service.conservation
                (\message ->
                    div [ class "cookies-regulation-service-conservation" ]
                        [ b [] [ text (Trans.modal_cookie_conservation locale) ]
                        , text message
                        ]
                )
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
            [ div [] [ text (Trans.modal_user_choices_conservation_duration model.locale) ]
            , div [] [ text (Trans.modal_user_choices_change model.locale) ]
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
        [ Button.view { label = Trans.modal_accept_all model.locale, type_ = Button.Primary, disabled = False, msg = MsgModalAcceptAll }
        , Button.view { label = Trans.modal_reject_all model.locale, type_ = Button.Primary, disabled = False, msg = MsgModalRejectAll }
        ]


decisionMetadataView : DecisionMetadata -> Html msg
decisionMetadataView metadata =
    div [ class "cookies-regulation-decision-metadata" ]
        [ div [] [ text metadata.uuid ]
        , div [] [ text metadata.date ]
        ]
