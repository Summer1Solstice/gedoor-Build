#!/bin/sh
#本脚本用来个性化定制app,不会修改任何程序代码
source $GITHUB_WORKSPACE/action_util.sh
#去除河蟹,默认启用
function app_clear_18plus() 
{
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "清空18PlusList.txt"
        echo "">$APP_WORKSPACE/app/src/main/assets/18PlusList.txt
    fi
}

#修改桌面阅读名为阅读.A,安装多个阅读时候方便识别,默认启用
function app_rename() 
{
    if [[ "$APP_NAME" == "legado" ]] ; then
        debug "更改桌面启动名称"
        sed 's/"app_name">阅读/"app_name">'"$APP_LAUNCH_NAME"'/' \
            $APP_WORKSPACE/app/src/main/res/values-zh/strings.xml -i
        debug "更改webdav备份目录legado为legado+后缀名"
        find $APP_WORKSPACE/app/src -regex '.*/storage/.*.kt' -exec \
        sed "s/\${url}legado/&$APP_SUFFIX/" {} -i \;
    fi
}

#和已有阅读共存,默认启用
function app_live_together()
{
    if [[ "$APP_NAME" == "legado" ]]; then
        debug "解决安装程序共存问题"
        sed "s/'.release'/'.release$APP_SUFFIX'/" \
            $APP_WORKSPACE/app/build.gradle -i
        sed "s/.release/.release$APP_SUFFIX/" \
            $APP_WORKSPACE/app/google-services.json -i
    fi
}
function unify_version_name()
{ 
    if [[ "$APP_TAG" == 3.* ]]; then
        debug "统一版本号"
        sed "/def version/c def version = \"$APP_TAG\"" $APP_WORKSPACE/app/build.gradle  -i
    else
        debug "APP_TAG 不是以 3. 开头，跳过版本号统一"
    fi
}
#apk增加签名,默认启用
function app_sign()
{
    debug "给apk增加签名"
    cp $GITHUB_WORKSPACE/.github/legado/legado.jks \
       $APP_WORKSPACE/app/legado.jks
    sed '$r '"$GITHUB_WORKSPACE/.github/legado/legado.sign"'' \
       $APP_WORKSPACE/gradle.properties -i
}

#签名
app_sign;
#阅读3.0
app_clear_18plus;
app_rename;
app_live_together;
unify_version_name;
