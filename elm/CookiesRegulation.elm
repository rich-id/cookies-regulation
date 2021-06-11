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


port setPreferences : ( Preferences, Bool ) -> Cmd msg


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
            getEnabledMandatoryServicesByPreferences flags.preferences mandatoryServices

        needUserAction_ =
            needUserAction mandatoryServices flags.preferences

        initialBandeauState =
            if needUserAction_ then
                BandeauNeedOpen

            else
                BandeauClosed
    in
    ( { website = flags.config.website
      , modal = flags.config.modal
      , privacyPolicy = flags.config.privacyPolicy
      , mandatoryServices = mandatoryServices
      , notMandatoryServices = filterNotMandatoryServices services
      , enabledMandatoryServices = enabledMandatoryServices
      , needUserAction = needUserAction_
      , bandeauState = initialBandeauState
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


needUserAction : Services -> Preferences -> Bool
needUserAction services preferences =
    let
        preferencesServiceIds =
            List.map (\( id, _ ) -> id) preferences
    in
    services
        |> Dict.keys
        |> List.map (\serviceId -> List.member serviceId preferencesServiceIds)
        |> Bool.all
        |> not



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
            applyServiceStatusChanges (setAllServicesEnabledAction model)

        MsgBandeauRejectAll ->
            applyServiceStatusChanges (setAllServicesDisabledAction model)

        MsgModalAcceptAll ->
            applyServiceStatusChanges (setAllServicesEnabledAction model)

        MsgModalRejectAll ->
            applyServiceStatusChanges (setAllServicesDisabledAction model)

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
            applyServiceStatusChanges model

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
    if model.modalState == ModalClosed then
        model

    else
        { model | modalState = ModalFadeClose }


resetNeedUserAction : Model -> Model
resetNeedUserAction model =
    { model | needUserAction = False }


setAllServicesEnabledAction : Model -> Model
setAllServicesEnabledAction model =
    { model | mandatoryServices = Dict.map (\_ service -> { service | enabled = True }) model.mandatoryServices }


setAllServicesDisabledAction : Model -> Model
setAllServicesDisabledAction model =
    { model | mandatoryServices = Dict.map (\_ service -> { service | enabled = False }) model.mandatoryServices }


recomputeEnabledMandatoryServicesAction : Model -> Model
recomputeEnabledMandatoryServicesAction model =
    { model | enabledMandatoryServices = getEnabledMandatoryServices model.mandatoryServices }


loadNotLoadedServices : Model -> List (Cmd msg)
loadNotLoadedServices model =
    model.mandatoryServices
        |> getEnabledMandatoryServices
        |> List.filter (\serviceId -> not (List.member serviceId model.enabledMandatoryServices))
        |> List.map initializeService


applyServiceStatusChanges : Model -> ( Model, Cmd msg )
applyServiceStatusChanges model =
    let
        hasRejectedService_ =
            hasRejectedService model

        loadServicesCmds =
            if hasRejectedService_ then
                []

            else
                loadNotLoadedServices model
    in
    ( model
        |> resetNeedUserAction
        |> recomputeEnabledMandatoryServicesAction
        |> closeBandeauAction
        |> closeModalAction
    , Cmd.batch ([ setPreferences ( buildPreferencesForSave model, hasRejectedService_ ) ] ++ loadServicesCmds)
    )



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
