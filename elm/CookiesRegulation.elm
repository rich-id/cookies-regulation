port module CookiesRegulation exposing (main)

import Bool.Extra as Bool
import Browser
import Browser.Dom exposing (Error, Viewport, getViewportOf)
import Browser.Events exposing (onResize)
import Dict exposing (Dict)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (id)
import Internal.CookiesRegulationBanner as CookiesRegulationBanner
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


port receiveDecisionMetadata : (DecisionMetadata -> msg) -> Sub msg



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
        bannerStateSub =
            case model.bannerState of
                BannerNeedOpen ->
                    Browser.Events.onAnimationFrame (\_ -> InternalMsgOpenBanner)

                _ ->
                    Sub.none
    in
    Sub.batch
        [ onResize InternalMsgResize
        , bannerStateSub
        , openModal (\_ -> MsgOpenModal)
        , receiveDecisionMetadata InternalMsgReceiveDecisionMetadata
        ]



-- Init


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        services =
            decodeServices flags

        notMandatoryServices =
            filterNotMandatoryServices services

        enabledNotMandatoryServices =
            getEnabledNotMandatoryServicesByPreferences flags.preferences notMandatoryServices

        needUserAction_ =
            needUserAction notMandatoryServices flags.preferences

        initialBannerState =
            if (not (Dict.isEmpty notMandatoryServices)) && needUserAction_ then
                BannerNeedOpen
            else if (not (Dict.isEmpty notMandatoryServices)) && not needUserAction_ then
                BannerClosed
            else if Dict.isEmpty notMandatoryServices && flags.decisionMetadata == Nothing then
                BannerNeedOpen
            else
                BannerClosed

        noConsentState =
            if not (Dict.isEmpty notMandatoryServices) then
                False

            else
                True
    in
    ( { website = flags.config.website
      , modal = flags.config.modal
      , privacyPolicy = flags.config.privacyPolicy
      , mandatoryServices = filterMandatoryServices services
      , notMandatoryServices = filterNotMandatoryServices services
      , enabledNotMandatoryServices = enabledNotMandatoryServices
      , needUserAction = needUserAction_
      , bannerState = initialBannerState
      , modalState = ModalClosed
      , modalBodyScrollable = False
      , locale = decodeLocale flags.config.locale
      , lastDecisionMetadata = flags.decisionMetadata
      , noConsent = noConsentState
      }
    , initializeServices services enabledNotMandatoryServices
    )


decodeServices : Flags -> Services
decodeServices flags =
    flags.config.services
        |> Decode.decodeValue (Decode.dict serviceConfigurationDecoder)
        |> Result.withDefault Dict.empty
        |> Dict.map
            (\serviceId service ->
                { service
                    | id = serviceId
                    , enabled = isSerciceEnabledByPreferences flags.preferences serviceId
                }
            )


initializeServices : Services -> List ServiceId -> Cmd msg
initializeServices services enabledServices =
    Cmd.batch
        (services
            |> Dict.filter
                (\serviceId service ->
                    service.mandatory || List.member serviceId enabledServices
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

        MsgBannerAcceptAll ->
            applyServiceStatusChanges (setAllServicesEnabledAction model)

        MsgBannerRejectAll ->
            applyServiceStatusChanges (setAllServicesDisabledAction model)

        MsgModalAcceptAll ->
            applyServiceStatusChanges (setAllServicesEnabledAction model)

        MsgModalRejectAll ->
            applyServiceStatusChanges (setAllServicesDisabledAction model)

        MsgUpdateServiceStatus serviceId ->
            ( { model
                | notMandatoryServices =
                    updateService model.notMandatoryServices
                        serviceId
                        (\service -> { service | enabled = not service.enabled })
              }
            , Cmd.none
            )

        MsgSave ->
            applyServiceStatusChanges model

        -- Internal
        InternalMsgOpenBanner ->
            ( { model | bannerState = BannerOpened }, Cmd.none )

        InternalMsgCloseBanner ->
            ( { model | bannerState = BannerClosed }, Cmd.none )

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

        InternalMsgReceiveDecisionMetadata decisionMetadata ->
            ( { model | lastDecisionMetadata = Just decisionMetadata }, Cmd.none )



-- Actions


openModalAction : Model -> Model
openModalAction model =
    { model | modalState = ModalOpened, modalBodyScrollable = False }


closeBannerAction : Model -> Model
closeBannerAction model =
    { model | bannerState = BannerFadeClose }


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
    { model | notMandatoryServices = Dict.map (\_ service -> { service | enabled = True }) model.notMandatoryServices }


setAllServicesDisabledAction : Model -> Model
setAllServicesDisabledAction model =
    { model | notMandatoryServices = Dict.map (\_ service -> { service | enabled = False }) model.notMandatoryServices }


recomputeEnabledNotMandatoryServicesAction : Model -> Model
recomputeEnabledNotMandatoryServicesAction model =
    { model | enabledNotMandatoryServices = getEnabledNotMandatoryServices model.notMandatoryServices }


loadNotLoadedServices : Model -> List (Cmd msg)
loadNotLoadedServices model =
    model.notMandatoryServices
        |> getEnabledNotMandatoryServices
        |> List.filter (\serviceId -> not (List.member serviceId model.enabledNotMandatoryServices))
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
        |> recomputeEnabledNotMandatoryServicesAction
        |> closeBannerAction
        |> closeModalAction
    , Cmd.batch ([ setPreferences ( buildPreferencesForSave model, hasRejectedService_ ) ] ++ loadServicesCmds)
    )

-- View


view : Model -> Html Msg
view model =
    div [ id "rich-id-cookies-regulation" ]
        [ CookiesRegulationBanner.view model
        , CookiesRegulationModal.view model
        ]



-- Internal


modalBodySizeCmd : Cmd Msg
modalBodySizeCmd =
    Task.attempt InternalMsgModalContentSize (getViewportOf "cookies-regulation-modal-body")
