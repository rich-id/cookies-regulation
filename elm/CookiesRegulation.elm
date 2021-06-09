module CookiesRegulation exposing (main)

import Browser
import Browser.Dom exposing (Error, Viewport, getViewportOf)
import Browser.Events exposing (onResize)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (id)
import Internal.CookiesRegulationBandeau as CookiesRegulationBandeau
import Internal.CookiesRegulationData exposing (..)
import Internal.CookiesRegulationModal as CookiesRegulationModal
import Json.Decode as Decode
import Task


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> onResize MsgResize
        }



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        services =
            flags.config.services
                |> Decode.decodeValue (Decode.dict serviceConfigurationDecoder)
                |> Result.withDefault Dict.empty
    in
    ( { config =
            { website = flags.config.website
            , privacyPolicy = flags.config.privacyPolicy
            , modal = flags.config.modal
            , services = services
            }
      , modalState = Close
      , modalBodyScrollable = False
      }
    , Cmd.none
    )



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgOpenModal ->
            ( { model | modalState = Open, modalBodyScrollable = False }, modalBodySizeCmd )

        MsgFadeCloseModal ->
            ( { model | modalState = FaseClose }, Cmd.none )

        MsgCloseModal ->
            ( { model | modalState = Close, modalBodyScrollable = False }, Cmd.none )

        MsgAcceptAll ->
            ( model, Cmd.none )

        MsgRejectAll ->
            ( model, Cmd.none )

        MsgSave ->
            ( model, Cmd.none )

        MsgResize _ _ ->
            ( model, modalBodySizeCmd )

        MsgModalContentSize result ->
            case result of
                Ok result_ ->
                    ( { model | modalBodyScrollable = model.modalState == Open && result_.viewport.height < result_.scene.height }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


modalBodySizeCmd : Cmd Msg
modalBodySizeCmd =
    Task.attempt MsgModalContentSize (getViewportOf "cookies-regulation-modal-body")



-- View


view : Model -> Html Msg
view model =
    div [ id "rich-id-cookies-regulation" ]
        [ CookiesRegulationBandeau.view model
        , CookiesRegulationModal.view model
        ]
