port module CookiesRegulation exposing (main)

import Bool.Extra as Bool
import Browser
import Browser.Dom exposing (Error, Viewport, getViewportOf)
import Browser.Events exposing (onResize)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (id)
import Internal.CookiesRegulationBandeau as CookiesRegulationBandeau
import Internal.CookiesRegulationData exposing (..)
import Internal.CookiesRegulationModal as CookiesRegulationModal
import Internal.Helpers exposing (..)
import Json.Decode as Decode
import Task



-- Ports Cmd


port modalOpened : () -> Cmd msg


port modalClosed : () -> Cmd msg


port setPreferences : Preferences -> Cmd msg


port initializeService : String -> Cmd msg



-- Ports Sub


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
                    Browser.Events.onAnimationFrame (\_ -> InternalMsgOpenBandeau)

                _ ->
                    Sub.none
    in
    Sub.batch [ onResize InternalMsgResize, bandeauStateSub, openModal (\_ -> MsgOpenModal) ]



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        services =
            decodeServices flags

        mandatoryServices =
            filterMandatoryServices services

        enabledMandatoryServices =
            getEnabledMandatoryServices flags.preferences mandatoryServices
    in
    ( { website = flags.config.website
      , modal = flags.config.modal
      , privacyPolicy = flags.config.privacyPolicy
      , mandatoryServices = mandatoryServices
      , notMandatoryServices = filterNotMandatoryServices services
      , enabledMandatoryServices = enabledMandatoryServices
      , bandeauState = initialBandeauState services flags.preferences
      , modalState = ModalClosed
      , modalBodyScrollable = False
      }
    , initializeServices services enabledMandatoryServices
    )


decodeServices : Flags -> Services
decodeServices flags =
    let
        isEnabled serviceId =
            flags.preferences
                |> List.filterMap
                    (\( key, value ) ->
                        if key == serviceId then
                            Just value

                        else
                            Nothing
                    )
                |> List.head
                |> Maybe.withDefault False
    in
    flags.config.services
        |> Decode.decodeValue (Decode.dict serviceConfigurationDecoder)
        |> Result.withDefault Dict.empty
        |> Dict.map
            (\serviceId service ->
                { service
                    | id = serviceId
                    , enabled = isEnabled serviceId
                }
            )


initializeServices : Services -> List ServiceId -> Cmd msg
initializeServices services enabledServices =
    Cmd.batch
        (services
            |> Dict.filter
                (\serviceId service ->
                    not service.mandatory || List.member serviceId enabledServices
                )
            |> Dict.keys
            |> List.map initializeService
        )


initialBandeauState : Services -> Preferences -> BandeauState
initialBandeauState services preferences =
    let
        preferencesServiceIds =
            List.map (\( id, _ ) -> id) preferences

        allServicesConfigured =
            services
                |> Dict.keys
                |> List.map (\serviceId -> List.member serviceId preferencesServiceIds)
                |> Bool.all
    in
    if allServicesConfigured then
        BandeauClosed

    else
        BandeauNeedOpen



-- Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgOpenModal ->
            ( model
                |> openModalAction
            , Cmd.batch [ modalOpened (), modalBodySizeCmd ]
            )

        MsgCloseModal ->
            ( model
                |> closeModalAction
            , Cmd.none
            )

        MsgBandeauAcceptAll ->
            ( model
                |> setAllServicesEnabledAction
                |> closeBandeauAction
            , setPreferences (buildAcceptAllPreferences model)
            )

        MsgBandeauRejectAll ->
            ( model
                |> setAllServicesDisabledAction
                |> closeBandeauAction
            , setPreferences (buildRejectAllPreferences model)
            )

        MsgModalAcceptAll ->
            ( model
                |> setAllServicesEnabledAction
                |> closeBandeauAction
                |> closeModalAction
            , setPreferences (buildAcceptAllPreferences model)
            )

        MsgModalRejectAll ->
            ( model
                |> setAllServicesDisabledAction
                |> closeBandeauAction
                |> closeModalAction
            , setPreferences (buildRejectAllPreferences model)
            )

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

        -- Internal
        InternalMsgOpenBandeau ->
            ( { model | bandeauState = BandeauOpened }, Cmd.none )

        InternalMsgCloseBandeau ->
            ( { model | bandeauState = BandeauClosed }, Cmd.none )

        InternalMsgCloseModal ->
            ( { model | modalState = ModalClosed, modalBodyScrollable = False }, modalClosed () )

        InternalMsgResize _ _ ->
            ( model, modalBodySizeCmd )

        InternalMsgModalContentSize result ->
            case result of
                Ok result_ ->
                    ( { model | modalBodyScrollable = model.modalState == ModalOpened && result_.viewport.height < result_.scene.height }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- Actions


openModalAction : Model -> Model
openModalAction model =
    { model | modalState = ModalOpened, modalBodyScrollable = False }


closeBandeauAction : Model -> Model
closeBandeauAction model =
    { model | bandeauState = BandeauFadeClose }


closeModalAction : Model -> Model
closeModalAction model =
    { model | modalState = ModalFadeClose }


setAllServicesEnabledAction : Model -> Model
setAllServicesEnabledAction model =
    { model | mandatoryServices = Dict.map (\_ service -> { service | enabled = True }) model.mandatoryServices }


setAllServicesDisabledAction : Model -> Model
setAllServicesDisabledAction model =
    { model | mandatoryServices = Dict.map (\_ service -> { service | enabled = False }) model.mandatoryServices }



-- View


view : Model -> Html Msg
view model =
    div [ id "rich-id-cookies-regulation" ]
        [ CookiesRegulationBandeau.view model
        , CookiesRegulationModal.view model
        ]



-- Internal


modalBodySizeCmd : Cmd Msg
modalBodySizeCmd =
    Task.attempt InternalMsgModalContentSize (getViewportOf "cookies-regulation-modal-body")
