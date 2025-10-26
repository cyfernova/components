#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

/// Build Registry Script
///
/// This script creates a production-ready registry for the Flutter component library.
/// It scans the components directory, generates SHA256 checksums for integrity validation,
/// and creates a manifest file that can be served from a CDN.
///
/// Usage: dart run build_registry.dart
///
/// The resulting structure will be:
/// dist/
/// ├── registry.json
/// └── components/
///     ├── button.dart
///     ├── card.dart
///     └── ...

class RegistryBuilder {
  static const String _componentsDir = 'lib/components';
  static const String _outputDir = 'dist';
  static const String _registryFile = 'registry.json';
  static const String _version = '1.0.0';

  Future<Map<String, dynamic>> _generateComponentRegistry() async {
    final componentsDir = Directory(_componentsDir);

    if (!await componentsDir.exists()) {
      throw Exception('Components directory not found: $_componentsDir');
    }

    final componentFiles = <String, dynamic>{};
    final componentJsonList = [];

    await for (final entity in componentsDir.list()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.path.split('/').last;
        final componentName = fileName.replaceAll('.dart', '');

        // Read component content
        final content = await entity.readAsString();

        // Generate SHA256 checksum
        final checksum = sha256.convert(utf8.encode(content)).toString();

        // Get file size
        final stat = await entity.stat();
        final fileSize = stat.size;

        // Get last modified timestamp
        final lastModified = stat.modified.toIso8601String();

        final componentInfo = {
          'name': componentName,
          'path': 'components/${fileName}',
          'version': _version,
          'checksum': checksum,
          'fileSize': fileSize,
          'lastModified': lastModified,
          'description': _extractDescription(content),
          'dependencies': _extractDependencies(content),
        };

        componentJsonList.add(componentInfo);
        componentFiles[componentName] = {
          'path': 'components/${fileName}',
          'version': _version,
          'checksum': checksum,
          'fileSize': fileSize,
          'lastModified': lastModified,
        };
      }
    }

    // Sort components alphabetically by name
    componentJsonList.sort((a, b) => a['name'].compareTo(b['name']));

    return {
      'registry': {
        'name': 'my_custom_component',
        'version': _version,
        'description': 'Flutter component library with animated UI components',
        'homepage': 'https://github.com/cyfernova/my_custom_component',
        'generatedAt': DateTime.now().toIso8601String(),
        'totalComponents': componentJsonList.length,
      },
      'components': componentFiles,
      'componentsDetailed': componentJsonList,
    };
  }

  String _extractDescription(String content) {
    // Try to extract description from the first comment block
    final descriptionMatch = RegExp(r'///\s*(.+?)(?=\n|$)').firstMatch(content);
    if (descriptionMatch != null) {
      return descriptionMatch.group(1)?.trim() ?? '';
    }

    // Fallback to class name extraction
    final classMatch = RegExp(r'class\s+(\w+)').firstMatch(content);
    if (classMatch != null) {
      final className = classMatch.group(1);
      return '${className} component';
    }

    return 'Flutter component';
  }

  List<String> _extractDependencies(String content) {
    final dependencies = <String>{};

    // Extract import statements for material, cupertino, and custom packages
    final importMatches = RegExp(r'''import\s+['"]([^'"]+)['"]''').allMatches(content);

    for (final match in importMatches) {
      final importPath = match.group(1);

      // Only include external dependencies, not relative imports
      if (importPath != null &&
          (importPath.startsWith('package:flutter/') ||
           importPath.startsWith('package:cupertino/') ||
           (!importPath.startsWith('.') && importPath.contains('package:')))) {
        dependencies.add(importPath);
      }
    }

    return dependencies.toList()..sort();
  }

  Future<void> _copyComponentFiles() async {
    final sourceDir = Directory(_componentsDir);
    final targetDir = Directory('$_outputDir/components');

    // Create target directory if it doesn't exist
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    // Copy all Dart files
    await for (final entity in sourceDir.list()) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final fileName = entity.path.split('/').last;
        final targetFile = File('${targetDir.path}/$fileName');

        await entity.copy(targetFile.path);
        print('Copied: $fileName -> ${targetFile.path}');
      }
    }
  }

  Future<void> _writeRegistryFile(Map<String, dynamic> registry) async {
    final registryFile = File('$_outputDir/$_registryFile');

    // Ensure output directory exists
    if (!await registryFile.parent.exists()) {
      await registryFile.parent.create(recursive: true);
    }

    // Write JSON with proper formatting
    final jsonString = const JsonEncoder.withIndent('  ').convert(registry);
    await registryFile.writeAsString(jsonString);

    print('Generated: ${registryFile.path}');
    print('Registry contains ${registry['components'].keys.length} components');
  }

  Future<void> _copyAdditionalFiles() async {
    // Copy pubspec.yaml for reference
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final targetFile = File('$_outputDir/pubspec.yaml');
      await pubspecFile.copy(targetFile.path);
      print('Copied: pubspec.yaml -> ${targetFile.path}');
    }

    // Copy README.md
    final readmeFile = File('README.md');
    if (await readmeFile.exists()) {
      final targetFile = File('$_outputDir/README.md');
      await readmeFile.copy(targetFile.path);
      print('Copied: README.md -> ${targetFile.path}');
    }
  }

  Future<void> validateBuild() async {
    final outputDirectory = Directory(_outputDir);
    final registryFile = File('$_outputDir/$_registryFile');

    if (!await outputDirectory.exists()) {
      throw Exception('Output directory was not created: $_outputDir');
    }

    if (!await registryFile.exists()) {
      throw Exception('Registry file was not created: ${registryFile.path}');
    }

    // Validate registry JSON format
    try {
      final content = await registryFile.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      if (!jsonData.containsKey('registry') || !jsonData.containsKey('components')) {
        throw Exception('Invalid registry format: missing required sections');
      }

      final componentCount = jsonData['components'].keys.length;
      if (componentCount == 0) {
        throw Exception('No components found in registry');
      }

      print('✅ Registry validation passed with $componentCount components');

    } catch (e) {
      throw Exception('Registry validation failed: $e');
    }
  }

  Future<void> build() async {
    print('🚀 Building Flutter component registry for CDN deployment...');

    try {
      // Clean output directory
      final outputDir = Directory(_outputDir);
      if (await outputDir.exists()) {
        await outputDir.delete(recursive: true);
        print('🧹 Cleaned existing output directory');
      }

      // Step 1: Generate component registry
      print('📋 Scanning components and generating metadata...');
      final registry = await _generateComponentRegistry();

      // Step 2: Copy component files
      print('📁 Copying component files...');
      await _copyComponentFiles();

      // Step 3: Copy additional files
      print('📄 Copying additional files...');
      await _copyAdditionalFiles();

      // Step 4: Write registry file
      print('💾 Writing registry manifest...');
      await _writeRegistryFile(registry);

      // Step 5: Validate build
      print('🔍 Validating build output...');
      await validateBuild();

      print('\n✅ Build completed successfully!');
      print('📦 Output directory: $_outputDir');
      print('🌐 Ready for CDN deployment to Cloudflare Pages');

      // Display component summary
      final componentCount = registry['components'].keys.length;
      print('\n📊 Build Summary:');
      print('   • Components: $componentCount');
      print('   • Version: $_version');
      print('   • Registry: $_registryFile');
      print('   • Output: $_outputDir/');

    } catch (e) {
      print('❌ Build failed: $e');
      exit(1);
    }
  }
}

void main(List<String> args) async {
  final builder = RegistryBuilder();
  await builder.build();
}