/// Conteneur générique type-safe pour la pagination Spring Data (`Page<T>`).
///
/// Décode directement la structure JSON standard émise par les contrôleurs Spring Boot :
/// - [content] : Liste typée des éléments de la page courante.
/// - [pageNumber] : Index de la page courante (0-indexed, correspond à `number` dans Spring Data).
/// - [pageSize] : Taille de page demandée (correspond à `size`).
/// - [totalElements] : Nombre total d'éléments dans la base.
/// - [totalPages] : Nombre total de pages disponibles.
/// - [isFirst] : Vrai si c'est la première page.
/// - [isLast] : Vrai si c'est la dernière page.
/// - [isEmpty] : Vrai si aucun élément n'est retourné.
class PageResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final int numberOfElements;
  final bool isFirst;
  final bool isLast;
  final bool isEmpty;

  const PageResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.numberOfElements,
    required this.isFirst,
    required this.isLast,
    required this.isEmpty,
  });

  /// Indique s'il existe une page suivante à charger (pour infinite scroll / pagination).
  bool get hasNext => !isLast;

  /// Indique s'il existe une page précédente.
  bool get hasPrevious => !isFirst;

  /// Index de la page suivante.
  int get nextPageNumber => pageNumber + 1;

  /// Index de la page précédente.
  int get previousPageNumber => pageNumber > 0 ? pageNumber - 1 : 0;

  /// Crée une page vide par défaut.
  factory PageResponse.empty() => const PageResponse(
        content: [],
        pageNumber: 0,
        pageSize: 20,
        totalElements: 0,
        totalPages: 0,
        numberOfElements: 0,
        isFirst: true,
        isLast: true,
        isEmpty: true,
      );

  /// Désérialisation adaptative depuis le JSON d'un objet `org.springframework.data.domain.Page`.
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic itemJson) fromJsonT,
  ) {
    final rawContent = json['content'];
    final contentList = rawContent is List
        ? rawContent.map((item) => fromJsonT(item)).toList()
        : <T>[];

    final pageNumber = (json['number'] as num?)?.toInt() ?? 0;
    final pageSize = (json['size'] as num?)?.toInt() ??
        (contentList.isNotEmpty ? contentList.length : 20);
    final totalElements =
        (json['totalElements'] as num?)?.toInt() ?? contentList.length;
    final totalPages =
        (json['totalPages'] as num?)?.toInt() ?? (totalElements > 0 ? 1 : 0);
    final isFirst = (json['first'] as bool?) ?? (pageNumber == 0);
    final isLast = (json['last'] as bool?) ?? (pageNumber >= totalPages - 1);
    final isEmpty = (json['empty'] as bool?) ?? contentList.isEmpty;
    final numberOfElements =
        (json['numberOfElements'] as num?)?.toInt() ?? contentList.length;

    return PageResponse<T>(
      content: contentList,
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalElements: totalElements,
      totalPages: totalPages,
      numberOfElements: numberOfElements,
      isFirst: isFirst,
      isLast: isLast,
      isEmpty: isEmpty,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T item) toJsonT) =>
      {
        'content': content.map((item) => toJsonT(item)).toList(),
        'number': pageNumber,
        'size': pageSize,
        'totalElements': totalElements,
        'totalPages': totalPages,
        'numberOfElements': numberOfElements,
        'first': isFirst,
        'last': isLast,
        'empty': isEmpty,
      };

  @override
  String toString() =>
      'PageResponse<$T>(page: $pageNumber/$totalPages, elements: $numberOfElements/$totalElements, hasNext: $hasNext)';
}
