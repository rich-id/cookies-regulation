module Internal.CookiesRegulationBanner exposing (view)

import Html exposing (Attribute, Html, a, div, span, text)
import Html.Attributes exposing (class, href, target)
import Html.Events as Events
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (BannerState(..), Model, Msg(..))
import Internal.Helpers exposing (..)
import Internal.Translations as Trans
import Json.Decode as Decode
import Html.Events exposing (onClick)
import Internal.Picto as Picto


view : Model -> Html Msg
view model =
    htmlWhenNot (model.bannerState == BannerClosed) <|
        div
            [ class "cookies-regulation-banner"
            , class "cookies-regulation-show" |> attrWhen (model.bannerState == BannerOpened)
            , Events.on "transitionend" (Decode.succeed InternalMsgCloseBanner) |> attrWhen (model.bannerState == BannerFadeClose)
            ]
            [ htmlWhen model.needUserAction <|
                div [ class "cookies-regulation-banner-contents" ]
                    [ span [ class "cookies-regulation-description" ] [ text <| Trans.banner_cookies_regulation model.locale ]
                    , Button.view { label = Trans.banner_customise model.locale, type_ = Button.Secondary, disabled = False, msg = MsgOpenModal }
                    , Button.view { label = Trans.modal_accept_all model.locale, type_ = Button.Primary, disabled = False, msg = MsgBannerAcceptAll }
                    , Button.view { label = Trans.modal_reject_all model.locale, type_ = Button.Primary, disabled = False, msg = MsgBannerRejectAll }
                    , a
                        [ class "cookies-regulation-privacy-policy"
                        , href model.privacyPolicy.url
                        , target "_blank" |> attrWhen model.privacyPolicy.openInNewWindow
                        ]
                        [ text model.privacyPolicy.label ]
                    ]
            , htmlWhen model.noConsent <|
                div [ class "cookies-regulation-banner-contents" ]
                    [ span [ class "cookies-regulation-description" ] [ text <| Trans.banner_cookies_no_consent model.locale]
                    , Button.view { label = Trans.banner_cookies_button_details model.locale, type_ = Button.Secondary, disabled = False, msg = MsgOpenModal }
                    , a
                        [ class "cookies-regulation-privacy-policy"
                        , href model.privacyPolicy.url
                        , target "_blank" |> attrWhen model.privacyPolicy.openInNewWindow
                        ]
                        [ text model.privacyPolicy.label ]
                    ]
                ,
                Picto.close [ class "float-end", onClick (if model.needUserAction then InternalMsgCloseBanner else MsgSave) ]

            ]
