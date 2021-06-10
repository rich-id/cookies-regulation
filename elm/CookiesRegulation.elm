port module CookiesRegulation exposing (main)

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


port modalOpened : () -> Cmd msg


port modalClosed : () -> Cmd msg


port openModal : (() -> msg) -> Sub msg


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        bandeauStateSub =
            case model.bandeauState of
                BandeauNeedOpen ->
                    Browser.Events.onAnimationFrame (\_ -> MsgOpenBandeau)

                _ ->
                    Sub.none
    in
    Sub.batch [ onResize MsgResize, bandeauStateSub, openModal (\_ -> MsgOpenModal) ]



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        services =
            decodeServices flags.config.services
    in
    ( { website = flags.config.website
      , modal = flags.config.modal
      , privacyPolicy = flags.config.privacyPolicy
      , mandatoryServices = filterMandatoryServices services
      , notMandatoryServices = filterNotMandatoryServices services
      , preferences = Nothing
      , bandeauState = BandeauNeedOpen
      , modalState = ModalClosed
      , modalBodyScrollable = False
      }
    , Cmd.none
    )


decodeServices : Decode.Value -> Services
decodeServices json =
    json
        |> Decode.decodeValue (Decode.dict serviceConfigurationDecoder)
        |> Result.withDefault Dict.empty


filterMandatoryServices : Services -> Services
filterMandatoryServices services =
    Dict.filter (\_ service -> service.mandatory) services


filterNotMandatoryServices : Services -> Services
filterNotMandatoryServices services =
    Dict.filter (\_ service -> not service.mandatory) services



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgOpenBandeau ->
            ( { model | bandeauState = BandeauOpened }, Cmd.none )

        MsgFadeCloseBandeau ->
            ( { model | bandeauState = BandeauFadeClose }, Cmd.none )

        MsgCloseBandeau ->
            ( { model | bandeauState = BandeauClosed }, Cmd.none )

        MsgOpenModal ->
            ( { model | modalState = ModalOpened, modalBodyScrollable = False }, Cmd.batch [ modalOpened (), modalBodySizeCmd ] )

        MsgFadeCloseModal ->
            ( { model | modalState = ModalFadeClose }, Cmd.none )

        MsgCloseModal ->
            ( { model | modalState = ModalClosed, modalBodyScrollable = False }, modalClosed () )

        MsgBandeauAcceptAll ->
            ( model, Cmd.none )

        MsgBandeauRejectAll ->
            ( model, Cmd.none )

        MsgModalAcceptAll ->
            ( model, Cmd.none )

        MsgModalRejectAll ->
            ( model, Cmd.none )

        MsgUpdateServiceStatus serviceId ->
            ( { model
                | mandatoryServices =
                    updateService model.mandatoryServices
                        serviceId
                        (\service -> { service | enabled = not service.enabled })
              }
            , Cmd.none
            )

        MsgSave ->
            ( model, Cmd.none )

        MsgResize _ _ ->
            ( model, modalBodySizeCmd )

        MsgModalContentSize result ->
            case result of
                Ok result_ ->
                    ( { model | modalBodyScrollable = model.modalState == ModalOpened && result_.viewport.height < result_.scene.height }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


modalBodySizeCmd : Cmd Msg
modalBodySizeCmd =
    Task.attempt MsgModalContentSize (getViewportOf "cookies-regulation-modal-body")


updateService : Services -> String -> (Service -> Service) -> Services
updateService services serviceId updater =
    services
        |> Dict.map
            (\key service ->
                if key == serviceId then
                    updater service

                else
                    service
            )



-- View


view : Model -> Html Msg
view model =
    div [ id "rich-id-cookies-regulation" ]
        [ CookiesRegulationBandeau.view model
        , CookiesRegulationModal.view model
        ]
