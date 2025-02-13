module Internal.Picto exposing (clock, close, padlock, share)

import Html exposing (Attribute, Html)
import Html.Attributes exposing (attribute, id)
import Svg exposing (path, svg)
import Svg.Attributes as SvgAttr


clock : Html msg
clock =
    svg [ SvgAttr.width "16", SvgAttr.height "16", SvgAttr.viewBox "0 0 16 16", attribute "role" "img", attribute "aria-hidden" "true" ]
        [ path
            [ SvgAttr.d "M8 0C3.58 0 0 3.58 0 8s3.58 8 8 8 8-3.58 8-8-3.58-8-8-8zm0 14.452c-3.565 0-6.452-2.887-6.452-6.452S4.435 1.548 8 1.548 14.452 4.435 14.452 8 11.565 14.452 8 14.452zm1.994-3.368l-2.74-1.99c-.1-.075-.157-.19-.157-.313V3.484c0-.213.174-.387.387-.387h1.032c.213 0 .387.174.387.387v4.57l2.155 1.569c.174.125.21.367.084.542l-.607.835c-.125.171-.367.21-.541.084z"
            , SvgAttr.transform "translate(-378 -255) translate(345 62) translate(32 70) translate(1 120) translate(0 3)"
            , id "cookies-regulation-clock-icon"
            ]
            []
        ]


close : List (Attribute msg) -> Html msg
close attrs =
    svg ([ SvgAttr.width "16", SvgAttr.height "16", SvgAttr.viewBox "0 0 16 16", attribute "role" "img", attribute "aria-hidden" "true" ] ++ attrs)
        [ path
            [ SvgAttr.d "M15.18 15.984c.088-.01.174-.033.258-.07l.12-.06.114-.073c.083-.083.148-.177.195-.281.047-.104.07-.214.07-.328 0-.115-.018-.216-.054-.305-.024-.059-.055-.114-.09-.166l-.059-.076L9.156 8l6.61-6.594c.073-.083.13-.174.171-.273.042-.1.063-.206.063-.32 0-.105-.02-.206-.063-.305-.027-.066-.062-.129-.104-.188l-.067-.086c-.073-.073-.162-.13-.266-.172C15.396.021 15.292 0 15.187 0c-.114 0-.22.02-.32.063-.099.041-.19.098-.273.171L8 6.844 1.406.234c-.083-.073-.174-.13-.273-.172C1.033.021.927 0 .813 0 .708 0 .604.02.5.063.43.09.368.124.312.166L.234.234C.161.318.104.41.062.508.021.607 0 .708 0 .812c0 .115.02.222.063.32.027.067.062.13.104.188l.067.086L6.86 8 .25 14.625c-.052.063-.096.138-.133.227-.024.059-.043.119-.055.18l-.015.093v.063c0 .218.075.406.226.562.121.125.264.203.428.235L.828 16c.115 0 .221-.02.32-.063.066-.027.129-.064.188-.11l.086-.077L8 9.14l6.625 6.594c.073.084.159.146.258.188.066.028.135.046.208.055l.089.007z"
            , SvgAttr.transform "translate(-1055 -86) translate(345 62) translate(710 24)"
            , id "cookies-regulation-close-icon"
            ]
            []
        ]


padlock : Html msg
padlock =
    svg [ SvgAttr.width "21", SvgAttr.height "26", SvgAttr.viewBox "0 0 21 26", attribute "role" "img", attribute "aria-hidden" "true" ]
        [ path
            [ SvgAttr.d "M17.94 26c.842 0 1.563-.293 2.162-.88.544-.534.841-1.166.89-1.897l.008-.222V12.353c0-.843-.3-1.559-.898-2.146-.6-.587-1.32-.88-2.162-.88h-.73V6.686c0-.917-.178-1.78-.534-2.587-.355-.825-.842-1.536-1.46-2.132C14.6 1.371 13.87.89 13.027.523 12.204.174 11.325 0 10.389 0 9.452 0 8.563.174 7.72.523c-.824.367-1.545.848-2.162 1.444-.618.596-1.104 1.307-1.46 2.132-.311.707-.486 1.455-.525 2.245l-.008.342v2.641H3.06c-.842 0-1.563.293-2.162.88S0 11.501 0 12.326V23c0 .825.3 1.532.898 2.119.6.587 1.32.88 2.162.88h14.88zM15.582 9.327H5.166V6.686c0-1.413.51-2.614 1.53-3.605 1.02-.99 2.25-1.485 3.692-1.485 1.44 0 2.667.495 3.678 1.485.943.925 1.446 2.033 1.509 3.325l.007.28v2.641zm2.358 14.472H3.06c-.224 0-.416-.078-.575-.234-.128-.125-.204-.27-.23-.436l-.009-.128V12.353c0-.22.08-.412.239-.577.159-.165.35-.248.575-.248h14.88c.224 0 .416.083.575.248.128.132.204.281.23.449l.009.128v10.648c0 .22-.08.408-.239.564-.127.125-.275.2-.444.225l-.131.009zm-7.44-3.604c.225 0 .416-.078.576-.234.127-.125.203-.276.229-.454l.01-.138v-3.356c.149-.11.266-.248.35-.413.084-.165.126-.349.126-.55v-.11c0-.349-.126-.647-.379-.894-.252-.248-.556-.372-.912-.372s-.664.124-.926.372c-.263.247-.394.545-.394.894 0 .018.005.036.015.055l.01.027.004.028c0 .201.042.385.126.55.084.165.192.303.323.413h.028v3.356c0 .239.08.436.238.592.16.156.351.234.576.234zm7.664 3.219c.131 0 .24-.046.323-.138.085-.092.127-.192.127-.302 0-.129-.042-.234-.127-.317-.084-.082-.192-.124-.323-.124H2.836l-.094.008c-.09.016-.166.054-.23.116-.084.083-.126.188-.126.317 0 .11.042.21.127.302.084.092.192.138.323.138h15.328z"
            , SvgAttr.transform "translate(-377 -692) translate(345 62) translate(32 70) translate(0 522) translate(0 38)"
            , id "cookies-regulation-padlock-icon"
            ]
            []
        ]


share : Html msg
share =
    svg [ SvgAttr.width "16", SvgAttr.height "16", SvgAttr.viewBox "0 0 16 16", attribute "role" "img", attribute "aria-hidden" "true" ]
        [ path
            [ SvgAttr.d "M12.25 9l-5 4.25c-.322.279-1-.021-1-.5v-2.5c-3.032.402-4.216 1.695-3.25 5.25.249.33-.294.678-.75.5C1.104 15.013 0 13.315 0 11.5c0-3.564 2.646-4.735 6.25-5V4.25c0-.657.677-.958 1-.5l5 4.25c.327.171.327.65 0 1zm3.5-1.25l-5-4c-.323-.456-1-.157-1 .5v.25l3 2.75c.374.246.572.674.5 1 .072.576-.126 1.004-.5 1.25l-3 2.75v.25c0 .658.678.956 1 .5l5-4c.327-.387.327-.863 0-1.25z"
            , SvgAttr.transform "translate(-378 -217) translate(345 62) translate(32 70) translate(1 82) translate(0 3)"
            , id "cookies-regulation-share-icon"
            ]
            []
        ]
