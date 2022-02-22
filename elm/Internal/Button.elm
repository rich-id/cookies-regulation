module Internal.Button exposing (ButtonType(..), view)

import Html exposing (Attribute, Html, button, text)
import Html.Attributes exposing (class, type_)
import Html.Events exposing (onClick)
import Internal.CookiesRegulationData exposing (Model, Msg)
import Internal.Helpers exposing (..)


type alias ButtonConfig msg =
    { label : String
    , type_ : ButtonType
    , disabled : Bool
    , msg : msg
    }


type ButtonType
    = Primary
    | Secondary


view : ButtonConfig Msg -> Html Msg
view config =
    button
        [ type_ "button"
        , class "cookies-regulation-button"
        , class "cookies-regulation-button-secondary" |> attrWhen (config.type_ == Secondary)
        , class "cookies-regulation-button-disabled" |> attrWhen config.disabled
        , onClick config.msg |> attrWhen (not config.disabled)
        ]
        [ text config.label ]
