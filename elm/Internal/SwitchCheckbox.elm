module Internal.SwitchCheckbox exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Internal.Helpers exposing (attrWhen)


type alias Configuration msg =
    { id : String
    , label : String
    , isChecked : Bool
    , msg_ : msg
    }


view : Configuration msg -> Html msg
view config =
    div
        [ class "cookies-regulation-switch-checkbox-container"
        , class "cookies-regulation-switch-checkbox-container-checked" |> attrWhen config.isChecked
        ]
        [ div [ class "cookies-regulation-switch-checkbox-input-container" ]
            [ label [ for config.id, class "label-hidden" ] [ text config.label ]
            , input
                [ class "cookies-regulation-switch-checkbox"
                , type_ "checkbox"
                , id config.id
                , checked config.isChecked
                , onClick config.msg_
                ]
                []
            , span [ class "cookies-regulation-switch-checkbox-rounded ", onClick config.msg_ ] []
            ]
        ]
