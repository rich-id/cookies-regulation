module Internal.CookiesRegulationData exposing (BannerState(..), DecisionMetadata, Flags, FlagsConfiguration, ModalState(..), Model, Msg(..), Preferences, PrivacyPolicy, Service, ServiceId, Services, decodeLocale, serviceConfigurationDecoder)

import Browser.Dom exposing (Error, Viewport)
import Dict exposing (Dict)
import Internal.Translations exposing (Locale(..))
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode



-- Flags


type alias Flags =
    { config : FlagsConfiguration
    , preferences : Preferences
    , decisionMetadata : Maybe DecisionMetadata
    , isCookiePresent : Bool
    }


type alias FlagsConfiguration =
    { website : String
    , privacyPolicy : PrivacyPolicy
    , modal : ModalConfiguration
    , services : Decode.Value
    , locale : String
    }



-- Model


type alias Model =
    { website : String
    , modal : ModalConfiguration
    , privacyPolicy : PrivacyPolicy
    , mandatoryServices : Services
    , notMandatoryServices : Services
    , enabledNotMandatoryServices : List ServiceId
    , needUserAction : Bool
    , bannerState : BannerState
    , modalState : ModalState
    , modalBodyScrollable : Bool
    , locale : Locale
    , lastDecisionMetadata : Maybe DecisionMetadata
    , noConsent : Bool
    , isCookiePresent : Bool
    }


type alias PrivacyPolicy =
    { url : String
    , label : String
    , openInNewWindow : Bool
    }


type alias ModalConfiguration =
    { header : String
    , headerWithoutConsent : String
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


type alias DecisionMetadata =
    { uuid : String
    , date : String
    }


type alias ServiceId =
    String


type ModalState
    = ModalClosed
    | ModalOpened
    | ModalFadeClose


type BannerState
    = BannerNeedOpen
    | BannerOpened
    | BannerFadeClose
    | BannerClosed



-- Msg


type Msg
    = MsgOpenModal
    | MsgCloseModal
    | MsgBannerAcceptAll
    | MsgBannerRejectAll
    | MsgModalAcceptAll
    | MsgModalRejectAll
    | MsgUpdateServiceStatus String
    | MsgSave
    | InternalMsgOpenBanner
    | InternalMsgCloseBanner
    | InternalMsgCloseModal
    | InternalMsgResize Int Int
    | InternalMsgModalContentSize (Result Error Viewport)
    | InternalMsgReceiveDecisionMetadata DecisionMetadata



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


decodeLocale : String -> Locale
decodeLocale locale =
    case locale of
        "fr" ->
            Fr

        _ ->
            En
