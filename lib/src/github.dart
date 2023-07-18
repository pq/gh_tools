import 'package:github/github.dart';

Future<List<Issue>> getIssues(
    {required Authentication auth, required RepositorySlug repo}) async {
  var github = GitHub(auth: auth);
  try {
    return github.issues.listByRepo(repo).toList();
  } on Exception catch (e) {
    print('exception caught fetching GitHub issues');
    print(e);
    print('(defaulting to an empty list)');
    return Future.value(<Issue>[]);
  }
}

Future<List<IssueLabel>> getLabels({
  required String owner,
  required String name,
  required Authentication auth,
}) async {
  var github = GitHub(auth: auth);
  var slug = RepositorySlug(owner, name);
  try {
    return github.issues.listLabels(slug).toList();
  } on Exception catch (e) {
    print('exception caught fetching GitHub labels');
    print(e);
    print('(defaulting to an empty list)');
    return Future.value(<IssueLabel>[]);
  }
}

bool isBug(Issue issue) => issue.labels.map((l) => l.name).contains('bug');
