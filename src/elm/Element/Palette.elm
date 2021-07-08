module Element.Palette exposing (..)

import Element exposing (Attribute, Color, rgb255, rgba255)
import Element.Background as Background
import Utils.Background as Background



-- Red


darkRed : Color
darkRed =
    rgb255 191 30 45


crimson : Color
crimson =
    rgb255 237 31 36


softRed : Color
softRed =
    rgb255 235 76 72


pinkRed : Color
pinkRed =
    rgb255 255 116 116



-- Orange


lightOrange : Color
lightOrange =
    rgb255 238 124 51


orange : Color
orange =
    rgb255 241 101 34



-- Gold


gold : Color
gold =
    rgb255 255 160 0


lightGold : Color
lightGold =
    rgb255 255 199 19


textYellow : Color
textYellow =
    rgb255 201 153 6


lightGreyYellow : Color
lightGreyYellow =
    rgb255 255 223 119


yellow : Color
yellow =
    rgb255 255 234 124


blockYellow : Color
blockYellow =
    rgb255 246 224 111


greyYellow : Color
greyYellow =
    rgba255 195 167 82 0.65



-- Green


green1 : Color
green1 =
    rgb255 29 78 52


green2 : Color
green2 =
    rgb255 24 95 57


green3 : Color
green3 =
    rgb255 29 113 69


green4 : Color
green4 =
    rgb255 31 141 82


green5 : Color
green5 =
    rgb255 37 168 98


green6 : Color
green6 =
    rgb255 51 177 109


green7 : Color
green7 =
    rgb255 25 181 88


green8 : Color
green8 =
    rgb255 91 201 120


green9 : Color
green9 =
    rgb255 142 243 167


green10 : Color
green10 =
    rgb255 164 255 186



-- Lime


lime4 : Color
lime4 =
    rgb255 113 175 68


lime5 : Color
lime5 =
    rgb255 119 193 66



-- Purple


purple1 : Color
purple1 =
    rgb255 31 15 39


purple2 : Color
purple2 =
    rgb255 45 22 59


purple3 : Color
purple3 =
    rgb255 66 40 82


purple4 : Color
purple4 =
    rgb255 122 71 153


purple5 : Color
purple5 =
    rgb255 146 80 186


purple6 : Color
purple6 =
    rgb255 190 104 241


purple7 : Color
purple7 =
    rgb255 204 130 248


purple8 : Color
purple8 =
    rgb255 211 150 248


purple9 : Color
purple9 =
    rgb255 233 185 255


purple10 : Color
purple10 =
    rgb255 238 214 253



-- Pink


pink7 : Color
pink7 =
    rgb255 170 64 159



-- Mauve


mauve4 : Color
mauve4 =
    rgb255 167 29 96



-- Yellow


yellow1 : Color
yellow1 =
    rgb255 82 79 3


yellow2 : Color
yellow2 =
    rgb255 142 130 23


yellow3 : Color
yellow3 =
    rgb255 175 158 12


yellow4 : Color
yellow4 =
    rgb255 198 182 16


yellow5 : Color
yellow5 =
    rgb255 206 201 26


yellow6 : Color
yellow6 =
    rgb255 229 222 25


yellow7 : Color
yellow7 =
    rgb255 255 241 0


yellow8 : Color
yellow8 =
    rgb255 255 253 20


yellow9 : Color
yellow9 =
    rgb255 250 250 101


yellow10 : Color
yellow10 =
    rgb255 255 255 94



-- Blue


blue1 : Color
blue1 =
    rgb255 7 28 65


blue2 : Color
blue2 =
    rgb255 12 43 94


blue3 : Color
blue3 =
    rgb255 25 68 146


blue4 : Color
blue4 =
    rgb255 13 105 165


blue5 : Color
blue5 =
    rgb255 38 170 224


blue6 : Color
blue6 =
    rgb255 97 181 239


blue7 : Color
blue7 =
    rgb255 50 187 236


blue8 : Color
blue8 =
    rgb255 92 222 255


blue9 : Color
blue9 =
    rgb255 134 228 253


blue10 : Color
blue10 =
    rgb255 160 230 250



-- Brown


brown1 : Color
brown1 =
    rgb255 57 35 21


brown2 : Color
brown2 =
    rgb255 55 44 31


brown3 : Color
brown3 =
    rgb255 97 62 16


brown5 : Color
brown5 =
    rgb255 119 76 40


brown6 : Color
brown6 =
    rgb255 141 103 52


brown7 : Color
brown7 =
    rgb255 167 123 82


brown8 : Color
brown8 =
    rgb255 192 158 115


brown9 : Color
brown9 =
    rgb255 225 205 147



-- Slate


slate5 : Color
slate5 =
    rgb255 172 169 105


slate4 : Color
slate4 =
    rgb255 110 110 78


slate6 : Color
slate6 =
    rgb255 151 140 94



-- Grey


grey5 : Color
grey5 =
    rgb255 125 125 125


grey4 : Color
grey4 =
    rgb255 72 72 72



-- Background


background1 : Attribute msg
background1 =
    Background.color background1_


background1_ : Color
background1_ =
    rgb255 255 251 179


background2 : Attribute msg
background2 =
    Background.color background2_


background2_ : Color
background2_ =
    rgb255 255 254 224


seedPodBackground : Attribute msg
seedPodBackground =
    Background.split
        { left = lime5
        , right = lime4
        }



-- Util


blueGrey : Color
blueGrey =
    rgb255 192 198 216


midnightBlue : Color
midnightBlue =
    rgb255 6 24 35


silver : Color
silver =
    rgb255 226 226 226


lightGray : Color
lightGray =
    rgb255 180 180 180


transparent : Color
transparent =
    rgba255 0 0 0 0


transparentGray : Color
transparentGray =
    rgba255 149 149 149 0.2


slateGrey : Color
slateGrey =
    rgb255 128 122 110


white : Color
white =
    rgb255 255 255 255


black : Color
black =
    rgb255 0 0 0
