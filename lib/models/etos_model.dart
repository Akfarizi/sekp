class EtosModel {
  final String uid;
  final String nama;
  final String periode;
  final int disiplin;
  final int inisiatif;
  final int kerjaSama;
  final int tanggungJawab;

  EtosModel({
    required this.uid,
    required this.nama,
    required this.periode,
    required this.disiplin,
    required this.inisiatif,
    required this.kerjaSama,
    required this.tanggungJawab,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'periode': periode,
      'disiplin': disiplin,
      'inisiatif': inisiatif,
      'kerjaSama': kerjaSama,
      'tanggungJawab': tanggungJawab,
    };
  }
}
