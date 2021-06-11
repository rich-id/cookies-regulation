module Internal.CookiesRegulationData exposing (BandeauState(..), Flags, FlagsConfiguration, ModalState(..), Model, Msg(..), Preferences, PrivacyPolicy, Service, ServiceId, Services, serviceConfigurationDecoder)

import Browser.Dom exposing (Error, Viewport)
import Dict exposing (Dict)
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
    }



-- Model


type alias Model =
    { website : String
    , modal : ModalConfiguration
    , privacyPolicy : PrivacyPolicy
    , mandatoryServices : Services
    , notMandatoryServices : Services
    , enabledServices : List ServiceId
    , bandeauState : BandeauState
    , modalState : ModalState
    , modalBodyScrollable : Bool
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
    { name : String
    , description : Maybe String
    , conservation : String
    , mandatory : Bool
    , enabled : Bool
    }


type alias Services =
    Dict String Service


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
        |> Decode.required "name" Decode.string
        |> Decode.required "description" (Decode.nullable Decode.string)
        |> Decode.required "conservation" Decode.string
        |> Decode.required "mandatory" Decode.bool
        |> Decode.hardcoded False
