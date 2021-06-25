module Element.Scale exposing
    ( corners
    , edges
    , extraLarge
    , extraSmall
    , large
    , medium
    , small
    )


extraSmall : number
extraSmall =
    5


small : number
small =
    10


medium : number
medium =
    16


large : number
large =
    40


extraLarge : number
extraLarge =
    80


edges : { top : number, bottom : number, left : number, right : number }
edges =
    { top = 0
    , bottom = 0
    , left = 0
    , right = 0
    }


corners : { bottomLeft : number, bottomRight : number, topLeft : number, topRight : number }
corners =
    { bottomLeft = 0
    , bottomRight = 0
    , topLeft = 0
    , topRight = 0
    }
