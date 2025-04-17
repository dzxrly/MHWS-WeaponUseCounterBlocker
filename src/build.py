import argparse
import json
import os
import re
import shutil
from datetime import datetime, timedelta, timezone

CONTRIBUTORS = [
    'Egg Targaryen',
]

LANG_LIST = [
    {
        'tag': 'ZH-Hans',
        'fonts': 'src/fonts/Noto_Sans_SC/static/NotoSansSC-Medium.ttf',
        'fmm_config': {
            'name': 'Weapon Usage Counter Blocker',
            'description': 'Weapon Usage Counter Blocker',
            'author': ', '.join(CONTRIBUTORS),
            'screenshot': 'src/assets/screenshot_ZH-Hans.png',
            'category': 'Gameplay',
            'homepage': 'https://www.nexusmods.com/monsterhunterwilds/mods/1913',
        },
    },
    {
        'tag': 'ZH-Hant',
        'fonts': 'src/fonts/Noto_Sans_TC/static/NotoSansTC-Medium.ttf',
        'fmm_config': {
            'name': 'Weapon Usage Counter Blocker',
            'description': 'Weapon Usage Counter Blocker',
            'author': ', '.join(CONTRIBUTORS),
            'screenshot': 'src/assets/screenshot_ZH-Hant.png',
            'category': 'Gameplay',
            'homepage': 'https://www.nexusmods.com/monsterhunterwilds/mods/1913',
        },
    },
    {
        'tag': 'EN-US',
        'fmm_config': {
            'name': 'Weapon Usage Counter Blocker',
            'description': 'Weapon Usage Counter Blocker',
            'author': ', '.join(CONTRIBUTORS),
            'screenshot': 'src/assets/screenshot_EN-US.png',
            'category': 'Gameplay',
            'homepage': 'https://www.nexusmods.com/monsterhunterwilds/mods/1913',
        },
    },
    {
        'tag': 'JA-JP',
        'fonts': 'src/fonts/Noto_Sans_JP/static/NotoSansJP-Medium.ttf',
        'fmm_config': {
            'name': 'Weapon Usage Counter Blocker',
            'description': 'Weapon Usage Counter Blocker',
            'author': ', '.join(CONTRIBUTORS),
            'screenshot': 'src/assets/screenshot_JA-JP.png',
            'category': 'Gameplay',
            'homepage': 'https://www.nexusmods.com/monsterhunterwilds/mods/1913',
        },
    },
    {
        'tag': 'KO-KR',
        'fonts': 'src/fonts/Noto_Sans_KR/static/NotoSansKR-Medium.ttf',
        'fmm_config': {
            'name': 'Weapon Usage Counter Blocker',
            'description': 'Weapon Usage Counter Blocker',
            'author': ', '.join(CONTRIBUTORS),
            'screenshot': 'src/assets/screenshot_KO-KR.png',
            'category': 'Gameplay',
            'homepage': 'https://www.nexusmods.com/monsterhunterwilds/mods/1913',
        },
    }
]

# source file settings
ORIGIN_LUA_FIEL = 'src/WpUsageCounterBlocker.lua'
I18N_FILE_DIR = 'src/i18n'
# action settings
WORK_TEMP_DIR = '.temp'
# save settings
MOD_ROOT_DIR = 'reframework'
MOD_NAME = 'WeaponUsageCounterBlocker'
LUA_SAVE_DIR = '{}/{}/{}'.format(WORK_TEMP_DIR, MOD_ROOT_DIR, 'autorun')
JSON_SAVE_DIR = '{}/{}/{}/{}'.format(WORK_TEMP_DIR, MOD_ROOT_DIR, 'data', MOD_NAME)
JSON_FILE_NAME_PREFIX = 'WeaponUsageCounterBlocker_'
USER_CONFIG_JSON_FILE_NAME = 'UserConfig.json'
FONTS_SAVE_DIR = '{}/{}/{}'.format(WORK_TEMP_DIR, MOD_ROOT_DIR, 'fonts')
FONTS_FILE_NAME = 'WeaponUsageCounterBlocker_Fonts_NotoSans'
VERSION_JSON_SAVE_PATH = 'version.json'
ZIP_FILE_PREFIX = 'WeaponUsageCounterBlocker_'
# fmm settings
COVER_FILE_NAME = 'cover.png'
INI_FILE_NAME = 'modinfo.ini'


def get_lua_i18n_json(
        tag: str,
) -> dict:
    with open(os.path.join(I18N_FILE_DIR, f'{tag}.json'), 'r', encoding='utf-8') as f:
        i18n_json = json.load(f)
    return i18n_json


def read_origin_lua() -> (str, str, str):
    with open(ORIGIN_LUA_FIEL, 'r', encoding='utf-8') as f:
        lua_str = f.read()
    # match local INTER_VERSION = "xxx" row and read the content in the double quotes
    mod_ver_match = re.search(
        r"local INTER_VERSION\s*=\s*['\"]([^'\"]+)['\"]", lua_str)
    mod_ver = mod_ver_match.group(1) if mod_ver_match else 'Unknown'
    return lua_str, mod_ver


def save_json(
        tag: str,
        i18n_json,
) -> None:
    final_json = i18n_json
    save_path = os.path.join(JSON_SAVE_DIR, f'{JSON_FILE_NAME_PREFIX}{tag}.json')
    with open(save_path, 'w', encoding='utf-8') as f:
        json.dump(final_json, f, ensure_ascii=False, indent=4)


def create_lua_by_i18n(
        tag: str,
        font_path: str = None,
) -> (str, str, str):
    lua_str, mod_ver = read_origin_lua()
    # match 'local LANG = ""' row and replace the content in the double quotes
    lua_str = lua_str.replace('local LANG = ""', f'local LANG = "{tag}"')
    # match 'local FONT_NAME = ""' row and replace the content in the double quotes
    if font_path is not None:
        lua_str = lua_str.replace('local FONT_NAME = ""',
                                  f'local FONT_NAME = "{font_path}"')
    # match 'local userConfigPath = ""' row and replace the content in the double quotes
    lua_str = lua_str.replace('local userConfigPath = ""',
                              f'local userConfigPath = "{MOD_NAME}/{USER_CONFIG_JSON_FILE_NAME}"')
    # match 'local i18nFilePath = ""' row and replace the content in the double quotes
    lua_str = lua_str.replace('local i18nFilePath = ""',
                              f'local i18nFilePath = "{MOD_NAME}/{JSON_FILE_NAME_PREFIX}{tag}.json"')
    # save lua file
    save_path = os.path.join(LUA_SAVE_DIR, f'WeaponUseCounterBlocker_{tag}.lua')
    with open(save_path, 'w', encoding='utf-8') as f:
        f.write(lua_str)
    return lua_str, mod_ver


def create_fmm_config(
        version: str,
        fmm_config: dict,
        save_dir: str,
) -> None:
    # cp cover.png to save_dir
    shutil.copyfile(fmm_config['screenshot'], os.path.join(
        save_dir, COVER_FILE_NAME))
    # create modinfo.ini
    with open(os.path.join(save_dir, INI_FILE_NAME), 'w', encoding='utf-8') as f:
        for key, value in fmm_config.items():
            if key == 'screenshot':
                f.write(f'{key}={COVER_FILE_NAME}\n')
            else:
                f.write(f'{key}={value}\n')
        f.write(f'version={version}\n')


def create_dir(path: str) -> None:
    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)


def init_dir() -> None:
    create_dir(os.path.join(WORK_TEMP_DIR, MOD_ROOT_DIR))
    create_dir(LUA_SAVE_DIR)
    create_dir(JSON_SAVE_DIR)
    create_dir(FONTS_SAVE_DIR)


def force_del_dir(
        path: str,
        debug_mode: bool = False,
) -> None:
    if os.path.exists(path) and not debug_mode:
        shutil.rmtree(path)


def create_zip(
        tag: str,
        src_dir: str,
        file_name_prefix: str,
) -> None:
    shutil.make_archive('{}{}'.format(file_name_prefix, tag), 'zip', root_dir=WORK_TEMP_DIR, base_dir='.')


if __name__ == '__main__':
    args = argparse.ArgumentParser()
    args.add_argument('-d', '--debug', action='store_true', help='Debug mode (Keep reframework dir)',
                      default=False)
    args.add_argument('-v', '--create_version_json', action='store_true', help='Create version.json',
                      default=False)
    args = args.parse_args()
    enable_debug = args.debug

    mod_version = 'Unknown'
    for lang in LANG_LIST:
        init_dir()
        lua_i18n_json = get_lua_i18n_json(lang['tag'])
        _, mod_version = create_lua_by_i18n(
            lang['tag'],
            '{}.{}'.format(
                FONTS_FILE_NAME, os.path.splitext(lang['fonts'])[-1].split('.')[-1]
            ) if 'fonts' in lang.keys() and lang['fonts'] is not None and lang['fonts'] != '' else None
        )
        save_json(lang['tag'], lua_i18n_json)
        # cp fonts to FONTS_SAVE_DIR
        if 'fonts' in lang.keys() and lang['fonts'] is not None and lang['fonts'] != '':
            shutil.copyfile(lang['fonts'], os.path.join(
                FONTS_SAVE_DIR, '{}.{}'.format(
                    FONTS_FILE_NAME, os.path.splitext(lang['fonts'])[-1].split('.')[-1]
                )))
        create_fmm_config(
            mod_version,
            lang['fmm_config'],
            WORK_TEMP_DIR
        )
        # create zip
        create_zip(lang['tag'], MOD_ROOT_DIR, ZIP_FILE_PREFIX)
        # del dir
        force_del_dir(WORK_TEMP_DIR, enable_debug)
    if not enable_debug and args.create_version_json:
        # save version.json
        version_json = {
            'version': mod_version,
            # set UTC +8 timezone date
            'build_date': '{} (UTC+8)'.format(
                (datetime.now(timezone.utc) + timedelta(hours=8)).strftime('%Y-%m-%d %H:%M:%S'))
        }
        with open(VERSION_JSON_SAVE_PATH, 'w', encoding='utf-8') as f:
            json.dump(version_json, f, ensure_ascii=False, indent=4)
        print('Done!')
