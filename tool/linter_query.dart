import 'dart:convert';

import 'package:args/args.dart';
import 'package:gh_tools/src/github.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

Future<void> main(List<String> args) async {
  var parser = ArgParser()
    ..addOption('token', abbr: 't', help: 'Specifies a GitHub auth token.');
  ArgResults options;
  try {
    options = parser.parse(args);
  } on FormatException catch (err) {
    printUsage(parser, err.message);
    return;
  }

  var rules = options.rest;
  if (rules.isEmpty) {
    printUsage(parser, 'At least one rule needs to be specified.');
    return;
  }

  var client = http.Client();
  var req = await client.get(
      Uri.parse('https://dart-lang.github.io/linter/lints/machine/rules.json'));

  var token = options['token'];
  var auth = token is String
      ? Authentication.withToken(token)
      : const Authentication.anonymous();

  var machine = json.decode(req.body) as Iterable;

  for (var rule in rules) {
    for (var entry in machine) {
      if (entry['name'] == rule) {
        print('https://dart-lang.github.io/linter/lints/$rule.html');
        print('');
        print('contained in: ${entry["sets"]}');
        var issues = await getIssues(
            auth: auth, repo: RepositorySlug('dart-lang', 'linter'));
        for (var issue in issues) {
          var title = issue.title;
          if (title.contains(rule)) {
            print('issue: ${issue.title}');
            print('labels: ${issue.labels.map((e) => e.name).join(", ")}');
            print(issue.htmlUrl);
            print('');
          }
        }
      }
    }
  }
}

void printUsage(ArgParser parser, [String? error]) {
  var message = error ??
      'Query lint rules for containing rule sets and relevant GH issues.';

  print('''$message
Usage: linter_query.dart rule_name
${parser.usage}
''');
}
