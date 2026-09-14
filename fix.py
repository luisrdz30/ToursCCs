import os

paths = [
    'd:/TFI/DocumentacionTurismo/app_turismo/lib/features/negocios/presentation/screens/negocio_create_promo_screen.dart',
    'd:/TFI/DocumentacionTurismo/app_turismo/lib/features/negocios/presentation/screens/tabs/negocio_promos_tab.dart',
    'd:/TFI/DocumentacionTurismo/app_turismo/lib/features/negocios/presentation/screens/tabs/negocio_dashboard_tab.dart',
    'd:/TFI/DocumentacionTurismo/app_turismo/lib/features/negocios/presentation/screens/negocio_scan_screen.dart',
    'd:/TFI/DocumentacionTurismo/app_turismo/lib/features/negocios/presentation/screens/tabs/negocio_profile_tab.dart'
]

for p in paths:
    if os.path.exists(p):
        content = open(p, 'r', encoding='utf-8').read()
        content = content.replace('\\${', '${')
        content = content.replace('\\$e', '$e')
        content = content.replace('\\$dateBadge', '$dateBadge')
        content = content.replace('\\$points', '$points')
        open(p, 'w', encoding='utf-8').write(content)
        print(f"Fixed {p}")
