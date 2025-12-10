// Language selector with inline content
// All locale content is embedded directly to work with file:// protocol

const locales = {
    en: {
        title: 'DEP Settings in Windows 10',
        body: `<div class="doc-content">
<p class="c5 title"><span class="c2 c9">The </span><span class="c2">DEP settings </span><span class="c2 c9">of</span><span class="c2">&nbsp;Windows 10</span></p>
<p class="c1 c3"><span class="c0"></span></p>
<p class="c1"><span class="c4">DEP (Data Execution Prevention) is a function found on Windows systems that prevents unauthorized programs from accessing reserved parts of system memory. In some cases, programs may be written in a way that requires access to these memory ranges, making it necessary to turn off DEP, at least for a selected program. This is a risky thing to do, </span><span class="c2">making your system less secure!</span><span class="c4 c11">&nbsp;But if you accept the risk, t</span><span class="c0">his quick tutorial will show you where to find the settings in question.</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">In Windows 10, there are at least </span><span class="c2">two different parameter settings</span><span class="c0">&nbsp;related to DEP, found in two completely different places in Windows settings.</span></p>

<p class="c1"><span class="c4">Here is the first one. </span><span class="c2">If you're trying to make Heroes 3 ERA work,</span><span class="c4">&nbsp;</span><span class="c2">try this first</span><span class="c0">: </span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Open Settings, click on '</span><span class="c2">Update &amp; Security</span><span class="c4">', from the menu on the left select '</span><span class="c2">Windows Security</span><span class="c4">', then from the 'Protection areas' menu select '</span><span class="c2">App &amp; browser control</span><span class="c4">'. In the window that opens, under 'Exploit protection' click on '</span><span class="c2">Exploit protection settings</span><span class="c4">'. The in the 'System settings' tab you will find the '</span><span class="c2">Data Execution Prevention (DEP)</span><span class="c4">' dropdown menu – select '</span><span class="c2 c6">Use default (On)</span><span class="c4">'. Finally, </span><span class="c2">reboot</span><span class="c0">&nbsp;the computer and try running Heroes 3 ERA. </span></p>

<p class="c1"><span class="c4">If </span><span class="c4 c6">that</span><span class="c4">&nbsp;doesn't work then </span><span class="c2">go back to the setting</span><span class="c4">&nbsp;and change it to '</span><span class="c2">Off by default</span><span class="c4">', </span><span class="c2">reboot</span><span class="c0">&nbsp;and try again – it should run.</span></p>

<p class="c1"><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 486.13px; height: 210.20px;"><img alt="" src="./dep-tutorial-content/images/image5.png" style="width: 486.08px; height: 434.06px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 451.20px; height: 273.53px;"><br><img alt="" src="./dep-tutorial-content/images/image7.png" style="width: 451.15px; height: 402.90px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 506.67px; height: 266.73px;"><img alt="" src="./dep-tutorial-content/images/image6.png" style="width: 506.63px; height: 266.69px; margin-left: 0.02px; margin-top: 0.02px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 508.87px; height: 267.93px;"><img alt="" src="./dep-tutorial-content/images/image2.png" style="width: 508.83px; height: 267.89px; margin-left: 0.02px; margin-top: 0.02px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1"><span class="c0">Short version:</span></p>

<p class="c1"><span class="c0">Settings &gt; Update &amp; Security &gt; Windows Security &gt; App &amp; browser control &gt; Exploit protection settings &gt; System settings &gt; 'Use default (On)'</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c0">If changing the setting above didn't help, you can try the second one. To find the second DEP setting, follow these directions:</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Open Settings, click on '</span><span class="c2">System</span><span class="c4">', from the menu on the left select '</span><span class="c2">About</span><span class="c4">', then scroll down and click '</span><span class="c2">Advanced system settings</span><span class="c4">'. In the window that opens, select the 'Advanced' tab and in the 'Performance' category, click the 'Settings...' button, opening another window. Then select the 'Data Execution Prevention' tab and choose the first option, DEP for essential only. Then </span><span class="c2">reboot</span><br><span class="c0">&nbsp;the computer.</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 476.00px; height: 428.27px;"><img alt="" src="./dep-tutorial-content/images/image1.png" style="width: 475.94px; height: 428.21px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 339.53px; height: 379.27px;"><img alt="" src="./dep-tutorial-content/images/image4.png" style="width: 339.43px; height: 379.18px; margin-left: 0.05px; margin-top: 0.05px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 282.40px; height: 401.60px;"><br><img alt="" src="./dep-tutorial-content/images/image3.png" style="width: 282.32px; height: 401.52px; margin-left: 0.04px; margin-top: 0.04px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<br><p class="c1"><span class="c0">Short version:</span></p>

<p class="c1"><span class="c0">Settings &nbsp;&gt; System &gt; About &gt; Advanced System Settings &gt; Advanced &gt; Performance &gt; Settings &gt; Data Execution Prevention</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 412.33px; height: 297.27px;"><img alt="" src="./dep-tutorial-content/images/image9.png" style="width: 412.28px; height: 297.21px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c0">The third way to change DEP settings involves using the command line.</span></p>

<p class="c1"><span class="c0">Open the command line as Administrator.</span></p>

<br>

<p class="c1"><span class="c2 c7">bcdedit.exe /set {current} nx OptIn &nbsp;</span></p>

<p class="c1"><span class="c0">to set DEP for critical and user-selected programs only, or </span></p>

<p class="c1"><span class="c2 c7">bcdedit.exe /set {current} nx AlwaysOff</span><span class="c2">&nbsp;</span><span class="c0">&nbsp;</span></p>

<p class="c1"><span class="c0">to turn DEP off fully.</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 664.67px; height: 126.00px;"><img alt="" src="./dep-tutorial-content/images/image8.png" style="width: 664.59px; height: 125.91px; margin-left: 0.04px; margin-top: 0.04px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1"><span class="c0">Feel free to consult this page for more information on how this setting may affect Heroes 3 ERA's attempt to call the SetProcessDEPPolicy function:</span></p>

<p class="c1"><span class="c4 c10"><a class="c8" href="https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setprocessdeppolicy">https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setprocessdeppolicy</a></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Again, after changing the setting make sure to </span><span class="c2">reboot</span><span class="c0">&nbsp;the computer.</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Finally, it needs to be said once again that </span><span class="c2">changing the DEP settings decreases your system's security, </span><span class="c11 c4">you do so at your own risk!</span></p>
</div>`
    },
    ru: {
        title: 'Настройки DEP в Windows 10',
        body: `<div class="doc-content">
<p class="c5 title"><span class="c2 c9">Настройки </span><span class="c2">DEP</span><span class="c2 c9"> </span><span class="c2">в Windows 10</span></p>
<p class="c1 c3"><span class="c0"></span></p>
<p class="c1"><span class="c4">DEP (Data Execution Prevention) — это функция в Windows, которая препятствует неавторизованным программам получить доступ к зарезервированным участкам памяти системы. В некоторых случаях программы могут быть написаны так, что им нужен доступ к этим диапазонам памяти, и тогда может потребоваться отключить DEP хотя бы для конкретного приложения. Это небезопасная операция, </span><span class="c2">которая снижает защиту вашей системы!</span><span class="c4 c11">&nbsp;Если вы принимаете этот риск,</span><span class="c0"> то в этом кратком руководстве показано, где находятся соответствующие настройки.</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">В Windows 10 как минимум </span><span class="c2">два разных места</span><span class="c0"> с параметрами, связанными с DEP — они находятся в разных разделах настроек.</span></p>

<p class="c1"><span class="c4">Вот первый вариант. </span><span class="c2">Если вы пытаетесь запустить Heroes 3 ERA,</span><span class="c4">&nbsp;</span><span class="c2">попробуйте начать с него</span><span class="c0">: </span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Откройте «Параметры», выберите «</span><span class="c2">Обновление и безопасность</span><span class="c4">», в меню слева выберите «</span><span class="c2">Безопасность Windows</span><span class="c4">», затем в разделе «Области защиты» выберите «</span><span class="c2">Проверка приложений и браузера</span><span class="c4">». В открывшемся окне в блоке «Защита от эксплойтов» нажмите «</span><span class="c2">Параметры защиты от эксплойтов</span><span class="c4">». На вкладке «Системные параметры» найдите выпадающее меню «</span><span class="c2">Предотвращение выполнения данных (DEP)</span><span class="c4">» — выберите «</span><span class="c2 c6">Использовать по умолчанию (Вкл)</span><span class="c4">». Наконец, </span><span class="c2">перезагрузите</span><span class="c0">&nbsp;компьютер и попробуйте запустить Heroes 3 ERA.</span></p>

<p class="c1"><span class="c4">Если </span><span class="c4 c6">это</span><span class="c4">&nbsp;не помогло, вернитесь к этому параметру и установите «</span><span class="c2">Отключено по умолчанию</span><span class="c4">», </span><span class="c2">перезагрузите</span><span class="c0">&nbsp;и попробуйте снова — программа должна запуститься.</span></p>

<p class="c1"><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 486.13px; height: 210.20px;"><img alt="" src="./dep-tutorial-content/images/image5.png" style="width: 486.08px; height: 434.06px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 451.20px; height: 273.53px;"><br><img alt="" src="./dep-tutorial-content/images/image7.png" style="width: 451.15px; height: 402.90px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 506.67px; height: 266.73px;"><img alt="" src="./dep-tutorial-content/images/image6.png" style="width: 506.63px; height: 266.69px; margin-left: 0.02px; margin-top: 0.02px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 508.87px; height: 267.93px;"><img alt="" src="./dep-tutorial-content/images/image2.png" style="width: 508.83px; height: 267.89px; margin-left: 0.02px; margin-top: 0.02px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<br><p class="c1"><span class="c0">Кратко:</span></p>

<p class="c1"><span class="c0">Параметры &gt; Обновление и безопасность &gt; Безопасность Windows &gt; Проверка приложений и браузера &gt; Параметры защиты от эксплойтов &gt; Системные параметры &gt; «Использовать по умолчанию (Вкл)»</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c0">Если изменение вышеприведённого параметра не помогло, попробуйте второй вариант. Чтобы найти второй параметр DEP, выполните следующие действия:</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Откройте «Параметры», выберите «</span><span class="c2">Система</span><span class="c4">», в меню слева выберите «</span><span class="c2">О программе</span><span class="c4">», затем прокрутите вниз и нажмите «</span><span class="c2">Дополнительные параметры системы</span><span class="c4">». В появившемся окне откройте вкладку «Дополнительно» и в разделе «Производительность» нажмите кнопку «Параметры...», откроется ещё одно окно. Выберите вкладку «Предотвращение выполнения данных» и установите первый вариант — DEP только для необходимых программ. Затем </span><span class="c2">перезагрузите</span><br><span class="c0">&nbsp;компьютер.</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 476.00px; height: 428.27px;"><img alt="" src="./dep-tutorial-content/images/image1.png" style="width: 475.94px; height: 428.21px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 339.53px; height: 379.27px;"><img alt="" src="./dep-tutorial-content/images/image4.png" style="width: 339.43px; height: 379.18px; margin-left: 0.05px; margin-top: 0.05px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span><br><br><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 282.40px; height: 401.60px;"><br><img alt="" src="./dep-tutorial-content/images/image3.png" style="width: 282.32px; height: 401.52px; margin-left: 0.04px; margin-top: 0.04px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<br><p class="c1"><span class="c0">Кратко:</span></p>

<p class="c1"><span class="c0">Параметры &nbsp;&gt; Система &gt; О программе &gt; Дополнительные параметры системы &gt; Дополнительно &gt; Производительность &gt; Параметры &gt; Предотвращение выполнения данных</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 412.33px; height: 297.27px;"><img alt="" src="./dep-tutorial-content/images/image9.png" style="width: 412.28px; height: 297.21px; margin-left: 0.03px; margin-top: 0.03px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c0">Третий способ изменить параметры DEP — через командную строку.</span></p>

<p class="c1"><span class="c0">Откройте командную строку от имени администратора.</span></p>

<br>

<p class="c1"><span class="c2 c7">bcdedit.exe /set {current} nx OptIn &nbsp;</span></p>

<p class="c1"><span class="c0">чтобы включить DEP только для критических и выбранных пользователем программ, или </span></p>

<p class="c1"><span class="c2 c7">bcdedit.exe /set {current} nx AlwaysOff</span><span class="c2">&nbsp;</span><span class="c0">&nbsp;</span></p>

<p class="c1"><span class="c0">чтобы полностью отключить DEP.</span></p>

<p class="c1"><span style="overflow: hidden; display: inline-block; margin: 0.00px 0.00px; border: 0.00px solid #000000; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px); width: 664.67px; height: 126.00px;"><img alt="" src="./dep-tutorial-content/images/image8.png" style="width: 664.59px; height: 125.91px; margin-left: 0.04px; margin-top: 0.04px; transform: rotate(0.00rad) translateZ(0px); -webkit-transform: rotate(0.00rad) translateZ(0px);" title=""></span></p>

<p class="c1"><span class="c0">Подробнее о том, как этот параметр может повлиять на попытку Heroes 3 ERA вызвать функцию SetProcessDEPPolicy, можно узнать по ссылке:</span></p>

<p class="c1"><span class="c4 c10"><a class="c8" href="https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setprocessdeppolicy">https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-setprocessdeppolicy</a></span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">Ещё раз: после изменения настроек обязательно </span><span class="c2">перезагрузите</span><span class="c0">&nbsp;компьютер.</span></p>

<p class="c1 c3"><span class="c0"></span></p>

<p class="c1"><span class="c4">И наконец, ещё раз стоит подчеркнуть, что </span><span class="c2">изменение настроек DEP снижает безопасность вашей системы,</span><span class="c11 c4"> вы делаете это на свой страх и риск!</span></p>
</div>`
    }
};

document.addEventListener('DOMContentLoaded', () => {
    const selector = document.getElementById('language-selector');
    const tutorialContainer = document.getElementById('tutorial-container');
    const siteTitle = document.getElementById('site-title');

    if (!selector || !tutorialContainer) return;

    selector.addEventListener('change', (event) => {
        const selectedLang = event.target.value;
        loadTutorial(selectedLang);
        try { localStorage.setItem('dep_tutorial_lang', selectedLang); } catch (e) {}
    });

    function loadTutorial(lang) {
        const locale = locales[lang];
        if (!locale) {
            tutorialContainer.innerHTML = '<p style="color:darkred;">Error: Language not found.</p>';
            return;
        }

        siteTitle.textContent = locale.title;
        tutorialContainer.innerHTML = locale.body;
        
        // Clean up excessive spans and merge text
        cleanupHTML(tutorialContainer);
    }
    
    function cleanupHTML(container) {
        // Remove only completely empty spans (no text, no children)
        const allSpans = container.querySelectorAll('span');
        allSpans.forEach(span => {
            // Only remove if truly empty: no text content and no child elements
            if (span.textContent.trim() === '' && span.children.length === 0) {
                span.remove();
            }
        });
    }

    // Load default language
    const saved = (function(){ try { return localStorage.getItem('dep_tutorial_lang'); } catch(e) { return null; }})();
    let defaultLang = saved || (navigator.language?.startsWith('ru') ? 'ru' : 'en');

    selector.value = defaultLang;
    loadTutorial(defaultLang);
});
