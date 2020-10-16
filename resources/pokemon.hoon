:-  %say
=<
|=  [[* eny=@uv *] *]
:-  %noun
=/  eevee  [%eevee `(set @tas)`(sy `(list @tas)`~[%normal]) `(set @tas)`(sy `(list @tas)`~[%growl %body-slam])]
=/  gyrados  [%gyrados `(set @tas)`(sy `(list @tas)`~[%water %flying]) `(set @tas)`(sy `(list @tas)`~[%bite %crunch %double-team])]
=/  unique-hash  `@uw`(~(raw og eny) 60)
=/  eevee-1  [unique-hash "Eevee" eevee 55 55 55 50 55]
~&  eevee
~&  gyrados
~&  eevee-1
eevee-1
|%
  +$  pokemon
    $%  id=@uw                    :: unique hash
        name=tape                 :: name of pokemon
        kind=species              :: kind of pokemon
        hp=@ud                    :: current health
        max-hp=@ud                :: normal maximum health
        attack=@ud                :: attack
        defense=@ud               :: defense
        speed=@ud                 :: speed
    ==
  +$  species
    $%  name=%tas                 :: pokemon species name as tag
        type=(set type)           :: pokemon types
        moves=(set move)          :: species-specific abilities
    ==
  +$  type  ?(%bug %dragon %ice %fighting %fire %flying %grass %ghost %ground %electric %normal %poison %psychic %rock %water)
  +$  move  ?(%barrage %bite %bind %body-slam %comet-punch %constrict %conversion %cut %crunch %disable %dizzy-punch %double-team %growl)
--

