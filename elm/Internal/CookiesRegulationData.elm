module Internal.CookiesRegulationData exposing (BandeauState(..), Flags, FlagsConfiguration, ModalState(..), Model, Msg(..), Preferences, PrivacyPolicy, Service, ServiceId, Services, decodeLocal, serviceConfigurationDecoder)

import Browser.Dom exposing (Error, Viewport)
import Dict exposing (Dict)
import Internal.Translations exposing (Local(..))
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode



-- Flags


type alias Flags =
    { config : FlagsConfiguration
    , preferences : Preferences
    }


type alias FlagsConfiguration =
    { website : String
    , privacyPolicy : PrivacyPolicy
    , modal : ModalConfiguration
    , services : Decode.Value
    , local : String
    }



-- Model


type alias Model =
    { website : String
    , modal : ModalConfiguration
    , privacyPolicy : PrivacyPolicy
    , mandatoryServices : Services
    , notMandatoryServices : Services
    , enabledMandatoryServices : List ServiceId
    , needUserAction : Bool
    , bandeauState : BandeauState
    , modalState : ModalState
    , modalBodyScrollable : Bool
    , local : Local
    }


type alias PrivacyPolicy =
    { url : String
    , label : String
    , openInNewWindow : Bool
    }


type alias ModalConfiguration =
    { header : String
    , relatedCompaniesCount : Int
    , relatedCompaniesPrivacyPolicyUrl : String
    }


type alias Service =
    { id : String
    , name : String
    , description : Maybe String
    , conservation : String
    , mandatory : Bool
    , enabled : Bool
    }


type alias Services =
    Dict ServiceId Service


type alias Preferences =
    List Preference


type alias Preference =
    ( ServiceId, Bool )


type alias ServiceId =
    String


type ModalState
    = ModalClosed
    | ModalOpened
    | ModalFadeClose


type BandeauState
    = BandeauNeedOpen
    | BandeauOpened
    | BandeauFadeClose
    | BandeauClosed



-- Msg


type Msg
    = MsgOpenModal
    | MsgCloseModal
    | MsgBandeauAcceptAll
    | MsgBandeauRejectAll
    | MsgModalAcceptAll
    | MsgModalRejectAll
    | MsgUpdateServiceStatus String
    | MsgSave
    | InternalMsgOpenBandeau
    | InternalMsgCloseBandeau
    | InternalMsgCloseModal
    | InternalMsgResize Int Int
    | InternalMsgModalContentSize (Result Error Viewport)



-- Decoder


serviceConfigurationDecoder : Decode.Decoder Service
serviceConfigurationDecoder =
    Decode.succeed Service
        |> Decode.hardcoded ""
        |> Decode.required "name" Decode.string
        |> Decode.required "description" (Decode.nullable Decode.string)
        |> Decode.required "conservation" Decode.string
        |> Decode.required "mandatory" Decode.bool
        |> Decode.hardcoded False


decodeLocal : String -> Local
decodeLocal local =
    case local of
        "fr" ->
            Fr

        _ ->
            En
