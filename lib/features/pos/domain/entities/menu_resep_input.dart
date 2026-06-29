/// One recipe line for a menu, sent in `POST /menus` (`resep[]`).
class MenuResepInput {
  const MenuResepInput({required this.bahanId, required this.jumlahPakai});

  final int bahanId;
  final double jumlahPakai;
}
