module Internal.CookiesRegulationBandeau exposing (view)

import Html exposing (Attribute, Html, a, div, span, text)
import Html.Attributes exposing (class, href, target)
import Html.Events as Events
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (BandeauState(..), Model, Msg(..))
import Internal.Helpers exposing (..)
import Internal.Translations as Trans
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    htmlWhenNot (model.bandeauState == BandeauClosed) <|
        div
            [ class "cookies-regulation-bandeau"
            , class "cookies-regulation-show" |> attrWhen (model.bandeauState == BandeauOpened)
            , Events.on "transitionend" (Decode.succeed InternalMsgCloseBandeau) |> attrWhen (model.bandeauState == BandeauFadeClose)
            ]
            [ div [ class "cookies-regulation-bandeau-contents" ]
                [ span [ class "cookies-regulation-description" ] [ text <| Trans.bandeau_cookies_regulation model.local ]
                , Button.view { label = "Personnaliser", type_ = Button.Secondary, disabled = False, msg = MsgOpenModal }
                , Button.view { label = "Tout accepter", type_ = Button.Primary, disabled = False, msg = MsgBandeauAcceptAll }
                , Button.view { label = "Tout refuser", type_ = Button.Primary, disabled = False, msg = MsgBandeauRejectAll }
                , a
                    [ class "cookies-regulation-privacy-policy"
                    , href model.privacyPolicy.url
                    , target "_blank" |> attrWhen model.privacyPolicy.openInNewWindow
                    ]
                    [ text model.privacyPolicy.label ]
                ]
            ]
