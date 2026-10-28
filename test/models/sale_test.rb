require "test_helper"

class SaleTest < ActiveSupport::TestCase
  test "met en forme une adresse DVF" do
    assert_equal "25 avenue de Marigny", Sale.format_address("25 AV DE MARIGNY")
    assert_equal "10 villa du Bel Air", Sale.format_address("10 VLA DU BEL AIR")
    assert_equal "3 rue Jean-Baptiste Pigalle", Sale.format_address("3 RUE JEAN-BAPTISTE PIGALLE")
    assert_equal "12 B rue d'Alésia", Sale.format_address("12 B RUE D'ALÉSIA")
    assert_equal "8 rue de l'Université", Sale.format_address("8 RUE DE L'UNIVERSITÉ")
    assert_equal "119 rue d'Avron", Sale.format_address("119 RUE D AVRON")
    assert_equal "4 D rue Oberkampf", Sale.format_address("4 D RUE OBERKAMPF")
    assert_equal "2 passage des Fours à Chaux", Sale.format_address("2 PAS DES FOURS A CHAUX")
  end

  test "gère une adresse vide" do
    assert_equal "", Sale.format_address(nil)
  end
end
