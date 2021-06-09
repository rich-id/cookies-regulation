module Internal.CookiesRegulationData exposing (Configuration, Flags, FlagsConfiguration, Model, Msg(..), PrivacyPolicy, Service, Services, serviceConfigurationDecoder)

import Browser.Dom exposing (Error, Viewport)
import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode



-- Flags


type alias Flags =
    { config : FlagsConfiguration }


type alias FlagsConfiguration =
    { website : String
    , privacyPolicy : PrivacyPolicy
    , modal : ModalConfiguration
    , services : Decode.Value
    }



-- Model


type alias Model =
    { config : Configuration
    , modalOpen : Bool
    , modalBodyScrollable : Bool
    }


type alias Configuration =
    { website : String
    , privacyPolicy : PrivacyPolicy
    , modal : ModalConfiguration
    , services : Services
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
    }


type alias Services =
    Dict String Service


type ModalState
    = Close
    | Open
    | FaseClose



-- Msg


type Msg
    = MsgOpenModal
    | MsgCloseModal
    | MsgAcceptAll
    | MsgRejectAll
    | MsgSave
    | MsgResize Int Int
    | MsgModalContentSize (Result Error Viewport)



-- Decoder


serviceConfigurationDecoder : Decode.Decoder Service
serviceConfigurationDecoder =
    Decode.succeed Service
        |> Decode.required "name" Decode.string
        |> Decode.required "description" (Decode.nullable Decode.string)
        |> Decode.required "conservation" Decode.string
        |> Decode.required "mandatory" Decode.bool
