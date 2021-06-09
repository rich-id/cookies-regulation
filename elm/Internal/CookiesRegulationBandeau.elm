module Internal.CookiesRegulationBandeau exposing (view)

import Html exposing (Attribute, Html, a, div, span, text)
import Html.Attributes exposing (class, href, target)
import Html.Events as Events
import Internal.Button as Button
import Internal.CookiesRegulationData exposing (BandeauState(..), Model, Msg(..))
import Internal.Helpers exposing (..)
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    htmlWhenNot (model.bandeauState == BandeauClosed) <|
        div
            [ class "cookies-regulation-bandeau"
            , class "show" |> attrWhen (model.bandeauState == BandeauOpened)
            , Events.on "transitionend" (Decode.succeed MsgCloseBandeau) |> attrWhen (model.bandeauState == BandeauFadeClose)
            ]
            [ span [ class "cookies-regulation-description" ] [ text "Contrôlez les cookies que nous utilisons pour ce site..." ]
            , Button.view { label = "Personnaliser", type_ = Button.Secondary, msg = MsgOpenModal }
            , Button.view { label = "Tout accepter", type_ = Button.Primary, msg = MsgFadeCloseBandeau }
            , Button.view { label = "Tout refuser", type_ = Button.Primary, msg = MsgRejectAll }
            , a
                [ class "cookies-regulation-privacy-policy"
                , href model.config.privacyPolicy.url
                , target "_blank" |> attrWhen model.config.privacyPolicy.openInNewWindow
                ]
                [ text model.config.privacyPolicy.label ]
            ]
