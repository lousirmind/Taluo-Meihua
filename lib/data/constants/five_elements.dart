class FiveElements {
  static const names = ['木', '火', '土', '金', '水'];

  static const sheng = {'木': '火', '火': '土', '土': '金', '金': '水', '水': '木'};
  static const ke = {'木': '土', '土': '水', '水': '火', '火': '金', '金': '木'};
  static const beiSheng = {'木': '水', '火': '木', '土': '火', '金': '土', '水': '金'};
  static const beiKe = {'木': '金', '火': '水', '土': '木', '金': '火', '水': '土'};

  static int indexOf(String e) => names.indexOf(e);

  /// 用生体 / 体用比和 / 体克用 / 体生用 / 用克体
  static String getTiYongRelation(String tiElement, String yongElement) {
    if (tiElement == yongElement) return '体用比和';
    if (sheng[yongElement] == tiElement) return '用生体';
    if (sheng[tiElement] == yongElement) return '体生用';
    if (ke[yongElement] == tiElement) return '用克体';
    if (ke[tiElement] == yongElement) return '体克用';
    return '体用比和';
  }
}
