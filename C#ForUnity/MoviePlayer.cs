using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MoviePlayer : MonoBehaviour
{

#if UNITY_STANDALONE_WIN || UNITY_EDITOR
    public MovieTexture[] movTextures;
    public string[] movieTextruePaths;

    MovieTexture currMovieTexture;
    Dictionary<string, MovieTexture> pathToMovies = new Dictionary<string, MovieTexture>();
#else
#endif
    int playingCountFrame;

    string[] moveSeqPath;
    int currMoveSeqIndex;
    bool isPlayingMovieSeq = false;
    bool canBreak = false;

    public void StartMovieSeq(string[] moveSeqPath, bool canBreak = false)
	{
        isPlayingMovieSeq = true;
        this.moveSeqPath = moveSeqPath;
        this.canBreak = canBreak;
        currMoveSeqIndex = 0;

        gameObject.SetActive(true);
        Play(moveSeqPath[currMoveSeqIndex]);
	}
    public bool IsPlaying()
    {
        return isPlayingMovieSeq;
    }

    void Start()
    {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR
        for (int i = 0; i < movTextures.Length; ++i)
            pathToMovies.Add(movieTextruePaths[i], movTextures[i]);
#else
#endif
        //string[] test = new string[1];
        //test[0] = "Demo1Scene-2015-9-28-82636s-1148x628.mp4";
        //StartMovieSeq(test, true);
    }

    void Play(string path)
    {

#if UNITY_STANDALONE_WIN || UNITY_EDITOR
        currMovieTexture = pathToMovies[path];
        if (currMovieTexture)
        {
            gameObject.SetActive(true);
            renderer.material.mainTexture = currMovieTexture;
            currMovieTexture.Play();
        }
#else
		Handheld.PlayFullScreenMovie(path, Color.black, canBreak ? FullScreenMovieControlMode.CancelOnInput : FullScreenMovieControlMode.Hidden);
#endif

        playingCountFrame = 0;
    }

    void Update()
    {
        bool isPlayNext = false;
        if (isPlayingMovieSeq)
            ++playingCountFrame;

#if UNITY_STANDALONE_WIN || UNITY_EDITOR
        if (isPlayingMovieSeq)
        {
            if (currMovieTexture.isPlaying)
            {
                if (canBreak && playingCountFrame > 30 && Input.GetMouseButton(0))
                    isPlayNext = true;
            }
            else
                isPlayNext = true;
        }
#else
        if (isPlayingMovieSeq && playingCountFrame > 10)
            isPlayNext = true;
#endif

        if (isPlayNext)
        {
            ++currMoveSeqIndex;
            if (currMoveSeqIndex >= moveSeqPath.Length)
            {
                isPlayingMovieSeq = false;
                gameObject.SetActive(false);
            }
            else
            {
                Play(moveSeqPath[currMoveSeqIndex]);
            }
        }
    }
}



