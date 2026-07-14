import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ProjectPaths {
  const ProjectPaths({required this.root, required this.cacheRoot});

  final Directory root;
  final Directory cacheRoot;

  static Future<ProjectPaths> resolve() async {
    final Directory support = await getApplicationSupportDirectory();
    final Directory cache = await getApplicationCacheDirectory();
    return ProjectPaths(
      root: Directory(p.join(support.path, 'stop_motion')),
      cacheRoot: Directory(p.join(cache.path, 'stop_motion')),
    );
  }

  File get databaseFile => File(p.join(root.path, 'stop_motion.sqlite'));
  Directory get projectsRoot => Directory(p.join(root.path, 'projects'));
  Directory get operationRoot => Directory(p.join(root.path, 'operations'));
  Directory get exportsRoot => Directory(p.join(root.path, 'exports'));

  Directory projectDirectory(String projectId) =>
      Directory(p.join(projectsRoot.path, projectId));

  Directory framesDirectory(String projectId) =>
      Directory(p.join(projectDirectory(projectId).path, 'frames'));

  Directory audioDirectory(String projectId) =>
      Directory(p.join(projectDirectory(projectId).path, 'audio'));

  Directory temporaryDirectory(String projectId) =>
      Directory(p.join(projectDirectory(projectId).path, '.tmp'));

  Directory exportDirectory(String projectId) =>
      Directory(p.join(exportsRoot.path, projectId));

  Directory exportTemporaryDirectory(String projectId) =>
      Directory(p.join(temporaryDirectory(projectId).path, 'exports'));

  Directory thumbnailDirectory(String projectId) =>
      Directory(p.join(cacheRoot.path, 'thumbnails', projectId));

  Future<void> ensureProject(String projectId) async {
    await framesDirectory(projectId).create(recursive: true);
    await audioDirectory(projectId).create(recursive: true);
    await temporaryDirectory(projectId).create(recursive: true);
  }

  String relativeToRoot(FileSystemEntity entity) =>
      p.relative(entity.path, from: root.path);

  File resolveRelativeFile(String relativePath) =>
      File(p.normalize(p.join(root.path, relativePath)));
}
