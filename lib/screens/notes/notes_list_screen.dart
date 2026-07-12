import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notes_controller.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColors = isDarkMode
        ? const [Color(0xFF08111F), Color(0xFF111A2D), Color(0xFF151E35)]
        : const [Color(0xFFF4F8FF), Color(0xFFEAF2FF), Color(0xFFFFFFFF)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Notes',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Capture ideas with a polished workspace',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : const Color(0xFF65788F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              onPressed: () => Get.toNamed('/create-note'),
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1F6FEB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColors,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -90,
                right: -50,
                child: _buildGlow(const Color(0xFF66A6FF).withOpacity(0.28), 200),
              ),
              Positioned(
                top: 120,
                left: -70,
                child: _buildGlow(const Color(0xFF7C5FD4).withOpacity(0.18), 220),
              ),
              Positioned(
                bottom: -80,
                left: 40,
                child: _buildGlow(const Color(0xFFFFB86B).withOpacity(0.12), 180),
              ),
              SafeArea(
                child: controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchNotes(),
                        color: Colors.white,
                        backgroundColor: const Color(0xFF1F6FEB),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                child: _buildSummaryHeader(context, controller, isDarkMode),
                              ),
                            ),
                            if (controller.notes.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(context, isDarkMode),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final note = controller.notes[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: _buildNoteCard(
                                          context,
                                          note: note,
                                          controller: controller,
                                          isDarkMode: isDarkMode,
                                          index: index,
                                        ),
                                      );
                                    },
                                    childCount: controller.notes.length,
                                  ),
                                ),
                              ),
                            const SliverToBoxAdapter(child: SizedBox(height: 90)),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-note'),
        backgroundColor: const Color(0xFF1F6FEB),
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0.0)],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(
    BuildContext context,
    NotesController controller,
    bool isDarkMode,
  ) {
    final noteCount = controller.notes.length;
    final latestNote = noteCount > 0 ? controller.notes.first : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF11284B),
                const Color(0xFF1F6FEB),
                const Color(0xFF7C5FD4).withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F6FEB).withOpacity(0.25),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$noteCount note${noteCount == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestNote == null
                                  ? 'Your workspace is ready for ideas'
                                  : 'Latest: ${latestNote.subject}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.84),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeroMetric(
                          'All Notes',
                          '$noteCount',
                          Icons.note_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeroMetric(
                          'Newest',
                          latestNote == null ? '--' : _formatDate(latestNote.createdAt),
                          Icons.schedule_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF101929) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF1F6FEB).withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.24 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F6FEB), Color(0xFF7C5FD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.note_add_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'No notes yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF10223A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a note to start building your study vault.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDarkMode ? Colors.white70 : const Color(0xFF65788F),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/create-note'),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6FEB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context, {
    required dynamic note,
    required NotesController controller,
    required bool isDarkMode,
    required int index,
  }) {
    final accentColors = [
      const Color(0xFF1F6FEB),
      const Color(0xFF7C5FD4),
      const Color(0xFFFF8F4D),
      const Color(0xFF3CCF91),
    ];
    final accent = accentColors[index % accentColors.length];

    return InkWell(
      onTap: () => Get.toNamed('/note-detail', arguments: note),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF101929) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: accent.withOpacity(0.16),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -18,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent.withOpacity(0.28), accent.withOpacity(0.10)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.note_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: isDarkMode
                                      ? Colors.white
                                      : const Color(0xFF10223A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _confirmDelete(context, controller, note.id),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5A6A).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFFF5A6A),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              note.subject,
                              accent,
                              isDarkMode,
                            ),
                            _buildChip(
                              _formatDate(note.createdAt),
                              isDarkMode ? Colors.white54 : const Color(0xFF65788F),
                              isDarkMode,
                              isMuted: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.45,
                            color: isDarkMode ? Colors.white70 : const Color(0xFF5E7086),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text, Color color, bool isDarkMode, {bool isMuted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMuted ? color.withOpacity(0.10) : color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isMuted ? color : color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmDelete(BuildContext context, NotesController controller, String noteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteNote(noteId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
