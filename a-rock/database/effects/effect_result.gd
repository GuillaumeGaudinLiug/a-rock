# effect_result.gd
class_name EffectResult
extends RefCounted

enum Kind { DAMAGE, DAMAGE_SP, HEAL, STATUS_APPLIED, STATUS_RESISTED, MISS, INFO }

var hit: bool = true
var value: float = 0.0            # dégâts infligés, soin appliqué, etc. (signe positif = gain, négatif = perte, à convention définir)
var value2: float = 0.0            # dégâts infligés, soin appliqué, etc. (signe positif = gain, négatif = perte, à convention définir)
var kind: Kind = Kind.INFO

var value_label: String = ""      # texte prêt à afficher, ex: "-42", "+20 EP", "Poison infligé"
var effect_name: String = ""      # pour distinguer plusieurs effets d'une même action dans les logs/UI
var status : StatusEffect
